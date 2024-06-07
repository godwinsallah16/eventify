import 'dart:io';

import '../domain/cloud_services/cloud_storage.dart';

class EventModel implements BaseModel {
  final String eventName;
  final String eventDescription;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final String? eventLocationUrl;
  final List<File>? eventFiles;
  final String? userReference; // This is the UID of the user
  String? userName;
  String? profileUrl;
  String? id;
  List<String>? comments;
  int loves;
  bool isLiked;

  EventModel(
      {required this.eventName,
      required this.eventDescription,
      required this.eventDate,
      required this.eventTime,
      required this.eventLocation,
      this.eventLocationUrl,
      this.eventFiles,
      this.userReference,
      this.userName,
      this.profileUrl,
      this.comments,
      this.loves = 0,
      this.isLiked = false,
      this.id});

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventName: json['eventName'],
      eventDescription: json['eventDescription'],
      eventDate: json['eventDate'],
      eventTime: json['eventTime'],
      eventLocation: json['eventLocation'],
      userName: json['userName'],
      profileUrl: json['profileUrl'],
      id: json['id'],
      eventLocationUrl: json['eventLocationUrl'],
      eventFiles: (json['eventFiles'] as List<dynamic>?)
          ?.map((fileJson) => File(fileJson.toString()))
          .toList(),
      userReference: json['userReference'],
      comments: (json['comments'] as List<dynamic>?)?.cast<String>(),
      loves: json['loves'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'eventDescription': eventDescription,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'eventLocation': eventLocation,
      'eventLocationUrl': eventLocationUrl,
      'eventFiles': eventFiles,
      'userReference': userReference,
      'userName': userName,
      'id': id,
      'profileUrl': profileUrl,
      'comments': comments,
      'loves': loves,
      'isLiked': isLiked,
    };
  }
}
