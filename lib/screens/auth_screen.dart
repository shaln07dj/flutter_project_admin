import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pauzible_app/Firebase/auth_helper.dart';
import 'package:pauzible_app/Models/app_state.dart';
import 'package:pauzible_app/redux/actions.dart';
import 'package:pauzible_app/redux/store.dart';

class AuthHomeScreen extends StatefulWidget {
  const AuthHomeScreen({Key? key}) : super(key: key);

  @override
  _AuthHomeScreenState createState() => _AuthHomeScreenState();
}

class _AuthHomeScreenState extends State<AuthHomeScreen> {
  void getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
// User ID
      String userEmail = user.email ?? ''; // User email
      String displayName = user.displayName ?? ''; // User display name
      String photoURL = user.photoURL ?? ''; // User photo URL
      String token = user.getIdToken as String;
      List<String> parts = displayName.split('');

      String firstName = parts.first;
      String lastName = parts.elementAt(1);

      // Use the user information as needed

      store.dispatch(UpdateAuthAction(
          firstName: firstName,
          lastName: lastName,
          displayName: displayName,
          userEmail: userEmail,
          photoUrl: photoURL,
          token: token));
    } else {
      print('No user is currently signed in.');
    }
  }

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String>(
        converter: (store) =>
            store.state.firstName ??
            '', // Replace 'firstName' with the field you want
        builder: (context, firstName) {
          var firstName = store.state.firstName;
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<ProfileScreen>(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                )
              ],
              automaticallyImplyLeading: false,
            ),
            body: Center(
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png'),
                  Text(
                    'Welcome $firstName!',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SignOutButton(),
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
        });
  }
}
