import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' hide PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pauzible_app/Helper/loading_widget.dart';
import 'package:pauzible_app/main.dart';
import 'package:pauzible_app/screens/admin_view.dart';
import 'package:pauzible_app/screens/user_update.dart';
import 'package:pauzible_app/widgets/logout.dart';
import 'package:pauzible_app/widgets/user_name_icon.dart';

class MultiFactorAuth extends StatefulWidget {
  bool? route;

  MultiFactorAuth({Key? key, this.route}) : super(key: key);

  @override
  State<MultiFactorAuth> createState() => _MultiFactorState();
}

class _MultiFactorState extends State<MultiFactorAuth> {
  final TextEditingController phoneController = TextEditingController();
  User? auth;
  var phoneNumber;
  var initialCountryCode = 'GB';
  // var initialCountryCode = 'IN';
  bool isPhoneNumberValid = false;

  Future<void> startPhoneVerification() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Get a multi-factor session
      final session = await user?.multiFactor.getSession();

      // Verify phone number
      await FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: session,
        phoneNumber: phoneNumber,
        verificationCompleted: (_) {},
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Verification failed: ${e.message} Code: ${e.code}');
          switch (e.code) {
            case 'requires-recent-login':
              Fluttertoast.showToast(
                  msg: "Idle Timeout - > Session time out, try again",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                  timeInSecForIosWeb: 2);
              SignOut();

            case 'too-many-requests':
              Fluttertoast.showToast(
                  msg: "Max retries : Wrong verification code, try again",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                  timeInSecForIosWeb: 2);
              SignOut();

            case 'invalid-phone-number':
              Fluttertoast.showToast(
                  msg:
                      "Invalid phone number: Please enter a valid phone number, try again",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                  timeInSecForIosWeb: 2);

            case 'operation-not-allowed':
              Fluttertoast.showToast(
                  msg: "Session time out, try again",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                  timeInSecForIosWeb: 2);
              SignOut();
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Get SMS code from user
          final smsCode = await getSmsCodeFromUser(context);

          if (smsCode != null) {
            // Create PhoneAuthCredential with the code
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            try {
              // Enroll in multi-factor authentication
              await user?.multiFactor.enroll(
                PhoneMultiFactorGenerator.getAssertion(credential),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => user!.displayName == null
                      ? const UserDetailUpdate()
                      : admin_view(
                          route: true,
                        ),
                ),
              );
            } on FirebaseAuthException catch (e) {
              debugPrint(
                  'Error enrolling in multi-factor: ${e.message} Code MFA: ${e.code}');

              switch (e.code) {
                case 'missing-code':
                  Fluttertoast.showToast(
                      msg: "You didn't enter verification code, try again",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                      timeInSecForIosWeb: 2);
                case 'invalid-verification-code':
                  Fluttertoast.showToast(
                      msg:
                          "Wrong Verification code  - Wrong verification code, try again",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                      timeInSecForIosWeb: 2);
              }
            }
          }
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      print('Error starting phone verification: $e');
    }
  }

  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                SignOut();
                Navigator.of(context).pop();
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String? nameInitial0;
    String? nameInitial;
    if (auth?.displayName != null) {
      nameInitial0 = auth?.displayName ?? '';
      nameInitial = nameInitial0[0].toUpperCase();
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0XFF0E5EB6),
        toolbarHeight: screenHeight * 0.089,
        title: Image.asset(
          'assets/images/logoo.png',
          width: screenWidth * 0.09,
        ),
        actions: [
          PopupMenuButton(
            tooltip: "Click to logout",
            surfaceTintColor: Colors.white,
            elevation: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: UserNameIcon(nameInitial: nameInitial),
            ),
            onSelected: (value) {
              if (value == "logout") {
                showLogoutConfirmationDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(right: 1),
                        child: Icon(
                          Icons.logout,
                          color: Color.fromARGB(255, 101, 98, 98),
                        )),
                    Text(
                      'Logout',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 500,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset('assets/images/registerbg.png'),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 80),
                child: SizedBox(
                  width: 500,
                  child: IntlPhoneField(
                    initialCountryCode: initialCountryCode,
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      floatingLabelStyle: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    languageCode: "en",
                    onChanged: (phone) {
                      if (RegExp(r'^[0-9]+$').hasMatch(phoneController.text)) {
                        setState(() {
                          phoneNumber =
                              "${phone.countryCode}${phoneController.text}";
                        });
                        if (phoneController.text.length == 10) {
                          setState(() {
                            isPhoneNumberValid = true;
                          });
                        }
                      } else {
                        print('Invalid phone number format');
                        setState(() {
                          isPhoneNumberValid = false;
                          phoneController.clear();
                        });
                      }
                    },
                    onCountryChanged: (country) {
                      print('Country changed to: ${country.code}');
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: ElevatedButton(
                  onPressed: isPhoneNumberValid ? startPhoneVerification : null,
                  child: const Text('Start Verification'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> getSmsCodeFromUser(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SmsCodeInputScreen2()),
    );
  }
}

typedef SMSCodeInputScreenBuilder = Widget Function(
  BuildContext context,
  List<FirebaseUIAction> actions,
  Object flowKey,
  AuthAction action,
);

class SmsCodeInputScreen2 extends StatefulWidget {
  const SmsCodeInputScreen2({Key? key}) : super(key: key);

  @override
  _SmsCodeInputScreenState createState() => _SmsCodeInputScreenState();
}

class _SmsCodeInputScreenState extends State<SmsCodeInputScreen2> {
  final List<TextEditingController> _smsCodeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter SMS Code',
                  style: TextStyle(fontSize: 14, color: Color(0xFF0E5EB6)),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    6,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5), // Adjust the horizontal padding
                      child: SizedBox(
                        width: 40,
                        child: TextField(
                          controller: _smsCodeControllers[index],
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(vertical: 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Adjust this value to reduce space
                ElevatedButton(
                  onPressed: () {
                    _verifySmsCode();
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(300,
                        5), // Set the width and height as per your requirement
                  ),
                  child: const Text('Verify'),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    _clearAllControllers();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(300,
                        5), // Set the width and height as per your requirement
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: LoadingWidget(),
              ),
            ),
        ],
      ),
    );
  }

  void _clearAllControllers() {
    for (var controller in _smsCodeControllers) {
      controller.clear();
    }
  }

  void _verifySmsCode() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate an async operation
    await Future.delayed(Duration(seconds: 2));

    final smsCode = _getSmsCode();
    Navigator.of(context).pop(smsCode);

    setState(() {
      _isLoading = false;
    });
  }

  String _getSmsCode() {
    return _smsCodeControllers.map((controller) => controller.text).join();
  }
}
