import 'package:eventify/models/events.dart';

import '../../core/app_export.dart';

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

class EventTile extends StatelessWidget {
  final EventModel event;
  final String defaultProfileUrl =
      'https://example.com/default_profile.png'; // Replace with your default profile image URL

  const EventTile({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          // Event Image
          Container(
            width: double.infinity,
            height: 400,
            color: Colors.grey, // Use a placeholder color if image is null
            child: event.eventFiles != null && event.eventFiles!.isNotEmpty
                ? Image.network(
                    event.eventFiles!.first.toString().replaceRange(0, 7, ""),
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: 300,
                  )
                : Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey,
                  ),
          ),
          // Icons vertically on the right
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.comment, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Gradient and details at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 90,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        event.profileUrl != null && event.profileUrl!.isNotEmpty
                            ? event.profileUrl!
                            : defaultProfileUrl,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            event.userName ?? 'Unknown User',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            event.eventName,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          Text(
                            '${event.eventLocation} - ${event.eventDate} at ${event.eventTime}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
