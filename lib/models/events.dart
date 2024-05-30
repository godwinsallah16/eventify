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

  EventModel({
    required this.eventName,
    required this.eventDescription,
    required this.eventDate,
    required this.eventTime,
    required this.eventLocation,
    this.eventLocationUrl,
    this.eventFiles,
    this.userReference,
    this.userName,
    this.profileUrl,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventName: json['eventName'],
      eventDescription: json['eventDescription'],
      eventDate: json['eventDate'],
      eventTime: json['eventTime'],
      eventLocation: json['eventLocation'],
      userName: json['userName'],
      profileUrl: json['profileUrl'],
      eventLocationUrl: json['eventLocationUrl'],
      eventFiles: (json['eventFiles'] as List<dynamic>?)
          ?.map((fileJson) => File(fileJson.toString()))
          .toList(),
      userReference: json['userReference'],
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
    };
  }
}
