import 'package:eventify/models/trending_events.dart';
import 'package:flutter/material.dart';

import '../../domain/cloud_services/fetch_events.dart';

class TrendingEvents extends StatefulWidget {
  const TrendingEvents({super.key});

  @override
  _TrendingEventsState createState() => _TrendingEventsState();
}

class _TrendingEventsState extends State<TrendingEvents>
    with SingleTickerProviderStateMixin {
  final EventService _eventService = EventService();
  late AnimationController _controller;
  late Animation<double> _animation; // Ensure animation is not nullable

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TrendingEvent>>(
      stream: _eventService.getTrendingEventsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Retry fetching data after a delay if there's an error
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() {});
            }
          });
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No events found.'));
        } else {
          const double cardWidth = 350;
          const double cardHeight = 195;

          return SizedBox(
            height: cardHeight, // Adjust the height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final event = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    // Handle image tap, navigate to detail or other action
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: Image.network(
                              event.imageUrl,
                              width: cardWidth,
                              height: cardHeight, // Adjust the height as needed
                              fit: BoxFit.fill,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return buildAnimatedGradient(
                                    cardWidth, cardHeight);
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return buildAnimatedGradient(
                                    cardWidth, cardHeight);
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(1),
                                    Colors.black.withOpacity(0.5),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Date: ${_eventService.formatDate(event.date)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Location: ${event.location}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget buildAnimatedGradient(double width, double height) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.black.withOpacity(0.4),
                Colors.white.withOpacity(0.4),
              ],
              stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        );
      },
    );
  }
}
