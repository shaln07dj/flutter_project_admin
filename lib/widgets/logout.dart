import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/api/skyflow/widgets/app.dart';
import 'package:pauzible_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignOut {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  SignOut() {
    _signOut();
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      navigateToLoginPage();
    } catch (e) {
      // Handle any sign out errors
      print('Error signing out: $e');
    }
  }

  void navigateToLoginPage() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const App()),
      (route) => false,
    );
  }
}
