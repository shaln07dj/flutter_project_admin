import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Firebase/auth_helper.dart';
import 'package:pauzible_app/widgets/footer.dart';
import 'package:pauzible_app/widgets/user_name_update_form.dart';

class UserDetailUpdate extends StatefulWidget {
  const UserDetailUpdate({Key? key}) : super(key: key);

  @override
  _UserDetailUpdateState createState() => _UserDetailUpdateState();
}

class _UserDetailUpdateState extends State<UserDetailUpdate> {
  void getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
    } else {}
  }

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Material(
      child: SizedBox(
        height: screenHeight * 0.80,
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenHeight * 0.07,
                  width: screenWidth,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.80,
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset('assets/images/registerbg.png'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.70,
                      child: const UserNameUpdateForm(),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
