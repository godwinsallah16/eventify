import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Import Flutter material library


class ForgotPasswordService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail(
      String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent successfully.");
      // Pass BuildContext to initUniLinks
    } catch (e) {
      print("Error sending password reset email: $e");
    }
  }
}
