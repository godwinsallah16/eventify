import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class SendMail {
  final String recipient;
  final String subject;
  static String username = "godwinsallah16@gmail.com";
  late String _password = "";
  final String _message;

  SendMail(this.recipient, this.subject, this._message);

  Future<bool> sendEmail(
      {Duration timeoutDuration = const Duration(seconds: 30)}) async {
    try {
      await fetchEmailPassword(); // Fetch the email password from Firestore

      final smtpServer = gmail(username, _password);

      final message = Message()
        ..from = Address(username, 'Eventify')
        ..recipients.add(recipient)
        ..subject = subject
        ..text = _message
        ..headers.addAll({'Reply-To': ''}); // Disable reply functionality

      final sendReport = await send(message, smtpServer)
          .timeout(timeoutDuration, onTimeout: () {
        throw TimeoutException('Email sending timed out');
      });

      // Dispose of the password after sending the email
      _password = ""; // Clear the password
      return sendReport != null; // Email sent successfully
    } on TimeoutException catch (e) {
      return false;
    } catch (e) {
      return false; // Error sending email
    }
  }

  Future<void> fetchEmailPassword() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await firestore.doc('appData/appCredentials').get();

      if (snapshot.exists) {
        final Map<String, dynamic> data = snapshot.data()!;
        _password = data['emailPassword'] ?? '';
        if (_password.isEmpty) {
          throw Exception('Email password is empty');
        } else {}
      } else {
        throw Exception('Document does not exist');
      }
    } catch (e) {
      throw Exception('Error fetching email password: $e');
    }
  }
}
