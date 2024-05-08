import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/redux/actions.dart';
import 'package:pauzible_app/redux/store.dart';

Future checkUser() async {
  User? user = FirebaseAuth.instance.currentUser;
  String userEmail = user?.email ?? '';
  String displayName = user?.displayName ?? '';
  String photoURL = user?.photoURL ?? '';
  String token = await user?.getIdToken() ?? '';
  List<String> parts = displayName.split('');

  String lastName = parts.length > 1 ? parts.elementAt(1) : '';
  debugPrint("Inside checkUser auth_helper");
  // Use the user information as needed
  user != null
      ? store.dispatch(UpdateAuthAction(
          firstName: "Smith",
          lastName: lastName,
          displayName: displayName,
          userEmail: userEmail,
          photoUrl: photoURL,
          token: token))
      : print('No user is currently signed in.');
}
