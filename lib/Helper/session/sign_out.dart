import 'package:firebase_auth/firebase_auth.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';

void signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
    clearSharedPreferences();
  } catch (e) {
    print('Error signing out: $e');
  }
}
