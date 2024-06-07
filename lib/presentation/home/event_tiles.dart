import 'package:eventify/models/events.dart';

import '../../core/app_export.dart';

class EventTile extends StatefulWidget {
  final EventModel event;
  final String defaultProfileUrl =
      'https://via.placeholder.com/150'; // New default profile image URL

  const EventTile({
    super.key,
    required this.event,
  });

  @override
  _EventTileState createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
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
            child: widget.event.eventFiles != null &&
                    widget.event.eventFiles!.isNotEmpty
                ? Image.network(
                    widget.event.eventFiles!.first
                        .toString()
                        .replaceRange(0, 7, ""),
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
          // Icons and likes count
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          size: 32,
                          Icons.favorite,
                          color: widget.event.isLiked
                              ? Colors.red
                              : Colors.grey[900],
                        ),
                        onPressed: () {
                          addLikeToEvent(context);
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _abbreviateNumber(widget.event.loves),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          size: 32,
                          Icons.comment,
                          color: widget.event.isLiked
                              ? Colors.red
                              : Colors.grey[900],
                        ),
                        onPressed: () {
                          addLikeToEvent(context);
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _abbreviateNumber(widget.event.loves),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          size: 32,
                          Icons.calendar_month,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _abbreviateNumber(widget.event.loves),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
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
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        widget.event.profileUrl != null &&
                                widget.event.profileUrl!.isNotEmpty
                            ? widget.event.profileUrl!
                            : widget.defaultProfileUrl,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.event.userName ?? 'Unknown User',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            widget.event.eventName,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          Text(
                            '${widget.event.eventLocation} - ${widget.event.eventDate} at ${widget.event.eventTime}',
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

  void addLikeToEvent(BuildContext context) async {
    try {
      setState(() {
        widget.event.isLiked = !widget.event.isLiked;
        widget.event.loves += widget.event.isLiked ? 1 : -1;
      });

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User ID not available');
      }

      // Update isLiked and loves properties in Firestore
      await FirebaseFirestore.instance
          .collection('public/events/users')
          .doc(widget.event.id)
          .update({
        'isLiked': widget.event.isLiked,
        'loves': widget.event.loves,
      });
      return;
    } catch (e) {
      return;
    }
  }

  String _abbreviateNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return '$number';
    }
  }
}
