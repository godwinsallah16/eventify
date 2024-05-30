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
        final userInfoDoc = await _firestore
            .collection('public')
            .doc('users')
            .collection('userInfo')
            .doc(event.userReference)
            .get();

        if (userInfoDoc.exists) {
          event.userName = userInfoDoc.get('userName');
          event.profileUrl = userInfoDoc.data()!.containsKey('profileUrl') &&
                  userInfoDoc.get('profileUrl').isNotEmpty
              ? userInfoDoc.get('profileUrl')
              : getInitialsFromUserName(event.userName ?? '');
        } else {
          event.userName = getInitialsFromUserName(event.userName ?? '');
          event.profileUrl = ''; // Use initials or a default image
        }
        events.add(event);
      }
      return events;
    });
  }

  String getInitialsFromUserName(String userName) {
    if (userName.isEmpty) return 'U';
    List<String> nameParts = userName.split(' ');
    if (nameParts.length == 1) {
      return userName.length > 1
          ? '${userName[0]}${userName[userName.length - 1]}'
          : userName[0];
    }
    return '${nameParts[0][0]}${nameParts[1][0]}';
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
