import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/update_displayname_helper.dart';

Future<void> updateDisplayName(String firstName, String lastName, String token,
    {required Function(bool status) handleUpdating}) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.updateProfile(displayName: '$firstName $lastName');

      await user.reload();

      user = FirebaseAuth.instance.currentUser;
      debugPrint("Inside updateDisplayName");

      updateSkyflowDisplayName(
        firstName,
        lastName,
        handleUpdating: handleUpdating,
      );

      debugPrint("Outside update display name, entering admin view");
    } else {
      debugPrint('No user signed in.');
    }
  } catch (e) {
    debugPrint('Error updating user display name: $e');
  }
}
