import 'package:eventify/models/events.dart';

import '../../core/app_export.dart';
import 'event_tiles.dart';

class EventList extends StatelessWidget {
  final EventService _eventService = EventService();

  EventList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EventModel>>(
      stream: _eventService.getEventsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching events.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No events available.'));
        } else {
          final events = snapshot.data!;
          return Column(
            children: events.map((event) => EventTile(event: event)).toList(),
          );
        }
      },
    );
  }
}
