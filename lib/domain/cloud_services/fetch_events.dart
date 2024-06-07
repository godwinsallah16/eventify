import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventify/models/events.dart';
import 'package:intl/intl.dart';

import '../../models/trending_events.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TrendingEvent>> getTrendingEventsStream() {
    return _firestore
        .collection('public')
        .doc('events')
        .collection('admin')
        .doc('trending')
        .collection('event_list')
        .snapshots()
        .map((snapshot) {
      print('Data fetched at ${DateTime.now()}'); // Log when data is fetched
      return snapshot.docs
          .map((doc) => TrendingEvent.fromJson(doc.data()))
          .toList();
    });
  }

  Stream<List<EventModel>> getEventsStream() {
    return _firestore
        .collection('public')
        .doc('events')
        .collection('users')
        .snapshots()
        .asyncMap((snapshot) async {
      List<EventModel> events = [];
      for (var doc in snapshot.docs) {
        EventModel event = EventModel.fromJson(doc.data());
        event.id = doc.id; // Assign the document ID as the event ID

        final userInfoDoc = await _firestore
            .collection('public')
            .doc('users')
            .collection('userInfo')
            .doc(event.userReference)
            .get();

        if (userInfoDoc.exists) {
          event.userName = userInfoDoc.get('userName');
          event.profileUrl = userInfoDoc.data()!.containsKey('profileUrl')
              ? userInfoDoc.get('profileUrl')
              : '';
        } else {
          event.userName = ''; // Set to an empty string
          event.profileUrl = ''; // Use initials or a default image
        }
        events.add(event);
      }
      return events;
    });
  }

  Future<Map<String, dynamic>> getComments(String eventId) async {
    try {
      QuerySnapshot commentSnapshot = await _firestore
          .collection('public')
          .doc('events')
          .collection('users')
          .doc(eventId)
          .collection('comments')
          .get();
      List<String> comments = [];
      for (var doc in commentSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?; // Explicit cast to Map
        if (data != null) {
          comments.add(data['comment'] as String? ?? '');
        }
      }
      int commentCount = comments.length;
      return {'comments': comments, 'commentCount': commentCount};
    } catch (e) {
      throw Exception('Error fetching comments: $e');
    }
  }

  Future<int> getLikesCount(String eventId) async {
    try {
      DocumentSnapshot eventSnapshot = await _firestore
          .collection('public')
          .doc('events')
          .collection('users')
          .doc(eventId)
          .get();
      if (eventSnapshot.exists) {
        return (eventSnapshot.data() as Map<String, dynamic>?)?['likes']
                as int? ??
            0;
      } else {
        throw Exception('Event not found');
      }
    } catch (e) {
      throw Exception('Error fetching likes count: $e');
    }
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    String day = DateFormat('d').format(parsedDate);
    String month = DateFormat('MMM').format(parsedDate).toUpperCase();

    String daySuffix;
    if (day.endsWith('1') && !day.endsWith('11')) {
      daySuffix = 'st';
    } else if (day.endsWith('2') && !day.endsWith('12')) {
      daySuffix = 'nd';
    } else if (day.endsWith('3') && !day.endsWith('13')) {
      daySuffix = 'rd';
    } else {
      daySuffix = 'th';
    }

    return '$day$daySuffix $month';
  }
}
