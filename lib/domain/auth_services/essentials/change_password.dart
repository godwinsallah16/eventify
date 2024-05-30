import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> changePassword(String newPassword) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        print('Password changed successfully');
      } catch (e) {
        print('Error changing password: $e');
        throw e;
      }
    } else {
      print('No user is signed in');
      throw Exception('No user is signed in');
    }
  }
}
