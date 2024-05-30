import 'package:flutter/material.dart';

class ButtonSecondary extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onTap;
  final bool? isLoading;

  const ButtonSecondary(
      {super.key,
      required this.buttonText,
      required this.onTap,
      this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color(0xFFD9D9D9)),
          shape: MaterialStateProperty.all(
            const ContinuousRectangleBorder(
              side: BorderSide(
                width: 2,
                style: BorderStyle.solid,
                color: Color(0xFFD9D9D9),
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
          elevation: MaterialStateProperty.all(5), // Add elevation for shadow
          shadowColor: MaterialStateProperty.all(Colors.black), // Shadow color
        ),
        onPressed:
            isLoading == true ? null : onTap, // Disable button if loading
        child: isLoading == true
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1578EC)),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontFamily: 'jost',
                    fontSize: 21,
                    color: Color(0xFF1578EC),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
      ),
    );
  }
}
