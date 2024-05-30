import 'package:eventify/presentation/home/trending_events.dart';
import 'package:flutter/material.dart';

import 'event_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF55CDF3),
              Color(0xFFDFF7FF),
              Colors.white,
            ],
            stops: [0.05, 0.1, 1],
          ),
        ),
        child: RefreshIndicator(
          color: Colors.blue,
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: TrendingEvents(),
              ),
              const SliverPadding(
                padding: EdgeInsets.all(8.0),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 16, // Adjust spacing if needed
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return EventList(); // Ensure EventList returns a constrained widget
                  },
                  childCount: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
