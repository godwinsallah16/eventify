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

      final newModelData = await _processModelData<T>(model, userId);

      String docId = useTimestamp
          ? '${userId}_${DateTime.now().millisecondsSinceEpoch}'
          : userId;

      final existingData = await _getExistingData(collectionPath, docId);

      final changedData = _getChangedData(existingData, newModelData);

      if (changedData.isNotEmpty) {
        await _saveToSpecifiedCollection(
          changedData,
          collectionPath,
          docId,
        );
      }
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
          if (file.existsSync()) {
            final downloadUrl = await _uploadFileToStorage(file);
            downloadUrls.add(downloadUrl);
          } else {
            throw Exception('File does not exist: ${file.path}');
          }
        }
        processedData[key] = downloadUrls;
      } else if (value is File) {
        if (value.existsSync()) {
          final downloadUrl = await _uploadFileToStorage(value);
          processedData[key] = downloadUrl;
        } else {
          throw Exception('File does not exist: ${value.path}');
        }
      } else if (value is String &&
          Uri.tryParse(value)?.hasAbsolutePath == true) {
        // If the value is a URL, add it directly to processedData
        processedData[key] = value;
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

  Future<Map<String, dynamic>> _getExistingData(
      String collectionPath, String docId) async {
    final docSnapshot =
        await _firestore.collection(collectionPath).doc(docId).get();
    return docSnapshot.exists ? docSnapshot.data() ?? {} : {};
  }

  Map<String, dynamic> _getChangedData(
      Map<String, dynamic> existingData, Map<String, dynamic> newData) {
    final changedData = <String, dynamic>{};

    newData.forEach((key, value) {
      if (!existingData.containsKey(key) || existingData[key] != value) {
        changedData[key] = value;
      }
    });

    return changedData;
  }

  Future<void> _saveToSpecifiedCollection(
      Map<String, dynamic> data, String collectionPath, String docId) async {
    await _firestore
        .collection(collectionPath)
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }
}

abstract class BaseModel {
  Map<String, dynamic> toMap();
}
