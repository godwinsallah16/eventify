import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/utils/image_constants.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  final Duration duration;

  const SplashScreen({
    super.key,
    this.duration = const Duration(seconds: 3),
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    // Start the sparkle animation
    _animationController.forward();
  }

  Future<String> initializeAndNavigate() async {
    bool userSignedIn = FirebaseAuth.instance.currentUser != null;
    return userSignedIn ? AppRoutes.mainScreen : AppRoutes.authInitScreen;
  }

  @override
  Widget build(BuildContext context) {
    String appName = "Eventify"; // Your app name

    return Scaffold(
      body: FutureBuilder<String>(
        future: initializeAndNavigate(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              _animationController.addStatusListener((status) {
                if (status == AnimationStatus.completed) {
                  Navigator.pushReplacementNamed(context, snapshot.data!);
                }
              });
            }
          }
          return Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  ImageConstant.splashLogo,
                  fit: BoxFit.cover,
                ),
              ),
              // Sparkle Animation
              Positioned.fill(
                child: SparkleAnimation(
                  animation: _animation,
                  context: context,
                ),
              ),
              // App Name Animation
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                        height: 500), // Adjust based on your background image
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Text(
                          appName.substring(
                              0, (appName.length * _animation.value).floor()),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class SparkleAnimation extends StatelessWidget {
  final Animation<double> animation;
  final BuildContext context; // Add context property

  const SparkleAnimation(
      {super.key, required this.animation, required this.context});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: SparklePainter(
              animation.value, this.context), // Pass context here
        );
      },
    );
  }
}

class SparklePainter extends CustomPainter {
  final double progress;
  final List<Sparkle> sparkles = [];
  final Random random = Random();
  final BuildContext context; // Add context property

  SparklePainter(this.progress, this.context) {
    _generateSparkles();
  }

  void _generateSparkles() {
    if (sparkles.isEmpty) {
      for (int i = 0; i < 25; i++) {
        sparkles.add(Sparkle(
          Offset(
            random.nextDouble() * MediaQuery.of(context).size.width,
            random.nextDouble() * MediaQuery.of(context).size.height,
          ),
          random.nextDouble() * 5,
        ));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      double radius = sparkle.radius * progress;
      final paint = Paint()
        ..color = Colors.white.withOpacity(1 - progress) // Fade out effect
        ..style = PaintingStyle.fill;

      canvas.drawCircle(sparkle.position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Sparkle {
  final Offset position;
  final double radius;

  Sparkle(this.position, this.radius);
}
