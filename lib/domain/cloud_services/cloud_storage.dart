import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> saveModelToDataBase<T extends BaseModel>({
    required T model,
    required String collectionPath,
    bool useTimestamp = false,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User ID not available');
      }

      final modelData = await _processModelData<T>(model, userId);

      String docId = useTimestamp
          ? '${userId}_${DateTime.now().millisecondsSinceEpoch}'
          : userId;

      await _saveToSpecifiedCollection(
        modelData,
        collectionPath,
        docId,
      );
    } catch (e) {
      throw Exception('Failed to save data: $e');
    }
  }

  Future<Map<String, dynamic>> _processModelData<T extends BaseModel>(
      T model, String userId) async {
    final modelMap = model.toMap();
    final processedData = <String, dynamic>{};

    for (var key in modelMap.keys) {
      final value = modelMap[key];
      if (value is List<File>) {
        final List<String> downloadUrls = [];
        for (var file in value) {
          final downloadUrl = await _uploadFileToStorage(file);
          downloadUrls.add(downloadUrl);
        }
        processedData[key] = downloadUrls;
      } else if (value is File) {
        final downloadUrl = await _uploadFileToStorage(value);
        processedData[key] = downloadUrl;
      } else {
        processedData[key] = value;
      }
    }

    // Add userReference field with userId
    processedData['userReference'] = userId;

    return processedData;
  }

  Future<String> _uploadFileToStorage(File file) async {
    try {
      final storageRef =
          _storage.ref().child('uploads/${file.uri.pathSegments.last}');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> _saveToSpecifiedCollection(
      Map<String, dynamic> data, String collectionPath, String docId) async {
    await _firestore.collection(collectionPath).doc(docId).set(data);
  }
}

abstract class BaseModel {
  Map<String, dynamic> toMap();
}
