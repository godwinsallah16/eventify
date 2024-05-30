import 'package:flutter/material.dart';

class RetryImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;

  const RetryImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    super.key,
  });

  @override
  _RetryImageState createState() => _RetryImageState();
}

class _RetryImageState extends State<RetryImage> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          Image.network(
            widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                _loading = false;
                return child;
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              }
            },
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              // Retry loading the image after a short delay
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {});
                }
              });
              return SizedBox(
                width: widget.width,
                height: widget.height,
                child: const Center(
                  child:
                      CircularProgressIndicator(), // Display a loading indicator while retrying
                ),
              );
            },
          ),
          if (_loading)
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: const Center(
                child:
                    CircularProgressIndicator(), // Display a loading indicator while initial loading
              ),
            ),
        ],
      ),
    );
  }
}
