import 'dart:math';

import 'package:eventify/core/app_export.dart';

class EmailOtpRegistrationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _otpTimer;
  static final Map<String, String> _otpMap =
      {}; // Make _otpMap static for persistence

  Future<bool> sendOtpEmail(String email) async {
    _otpMap.clear(); // Clear the OTP map at the beginning of the method
    String otpCode = _generateOtpCode().toString();
    const String subject = "Your OTP Code";
    final String otpMessage =
        "$otpCode is your verification code. For your security, do not share this code.";
    final sendMail = SendMail(email, subject, otpMessage);
    bool emailSentSuccessfully = await sendMail.sendEmail();
    if (emailSentSuccessfully) {
      print("Email sent successfully");
    } else {
      print("Error sending email");
      return false; // Return false if the email fails to send
    }
    _otpMap[email] = otpCode; // Store OTP using email as key
    _startOtpTimer(email); // Start timer for OTP removal
    return true;
  }

  Future<bool> verifyOtpCode(
      String email, String confirmCode, String password) async {
    try {
      if (_otpMap.containsKey(email) && _otpMap[email] == confirmCode) {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await _auth.currentUser!.sendEmailVerification();
        _otpTimer?.cancel(); // Cancel timer for this email
        _otpMap.remove(email); // Remove OTP from map
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  int _generateOtpCode() {
    return _generateRandomNumber(100000, 999999);
  }

  int _generateRandomNumber(int min, int max) {
    return min + Random().nextInt(max - min + 1);
  }

  void _startOtpTimer(String email) {
    _otpTimer?.cancel(); // Cancel previous timer if any
    _otpTimer = Timer(const Duration(minutes: 5), () {
      _otpMap.remove(email); // Remove OTP after 5 minutes
      print('Removed OTP for email $email after timeout');
    });
  }
}
