import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:local_session_timeout/local_session_timeout.dart';
import 'package:pauzible_app/Helper/get_token_helper.dart';
import 'package:pauzible_app/Helper/loading_widget.dart';
import 'package:pauzible_app/main.dart';
import 'package:pauzible_app/redux/actions.dart';
import 'package:pauzible_app/redux/store.dart';
import 'package:pauzible_app/screens/admin_view.dart';
import 'package:pauzible_app/screens/multi_factor.dart';
import 'package:pauzible_app/screens/user_update.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Timer _timer;

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void setTimer() {
    debugPrint("timer start");
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        debugPrint("Email verified from timer");
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiFactorAuth(
              route: true,
            ),
          ),
        );
      }
    });
  }

  Future<String> _getIdToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? idToken = await user?.getIdToken() ?? '';
    String? userId = user?.uid;
    String? userEmail = user?.email;
    store.dispatch(
      UpdateAuthAction(
        userEmail: userEmail,
        userId: userId,
      ),
    );

    try {
      Response response = await getToken(idToken);
    } catch (error) {
      // Handle errors
      debugPrint('Error: $error');
    }
    return idToken;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          final mfaAction = AuthStateChangeAction<MFARequired>(
            (context, state) async {
              Navigator.of(context);
              await startMFAVerification(
                resolver: state.resolver,
                context: context,
              );
              print('ADMIN VIEW');
              // final token = await _getIdToken();

              // token == ''
              //     ? debugPrint("no token")
              //     : nav.pushReplacement(
              //         MaterialPageRoute(
              //           builder: (context) => admin_view(route: true),
              //         ),
              //       );
            },
          );

          return SignInScreen(
            actions: [mfaAction],
            providers: [
              EmailAuthProvider(),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    'assets/images/logo.png',
                  ),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Login to Dashboard account')
                    : const Text('Login to Dashboard account'),
              );
            },
            footerBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'By signing in, you agree to our ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://www.pauzible.com/privacy');
                          },
                      ),
                      const TextSpan(
                        text: ' and the ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextSpan(
                        text: 'Terms of Use.',
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://www.pauzible.com/terms-of-use');
                          },
                      ),
                    ],
                  ),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/registerbg.png'),
                ),
              );
            },
          );
        } else {
          return FutureBuilder<String>(
            future: _getIdToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                store.dispatch(UpdateAuthAction(token: snapshot.data!));

                return FutureBuilder<List<MultiFactorInfo>>(
                  future: FirebaseAuth.instance.currentUser!.multiFactor
                      .getEnrolledFactors(),
                  builder: (context, factorsSnapshot) {
                    if (factorsSnapshot.connectionState ==
                        ConnectionState.done) {
                      if (factorsSnapshot.hasData) {
                        // Check if email is verified
                        if (FirebaseAuth.instance.currentUser!.emailVerified) {
                          // Check if there are enrolled factors
                          if (factorsSnapshot.data!.length > 0) {
                            debugPrint("Line 192 inside IF isNotEmpty");
                            return FirebaseAuth
                                        .instance.currentUser!.displayName ==
                                    null
                                ? const UserDetailUpdate()
                                : admin_view(
                                    route: true,
                                  );
                          } else {
                            debugPrint("Line 192 inside ELSE isNotEmpty");
                            return MultiFactorAuth(route: true);
                          }
                        } else {
                          setTimer();
                          return EmailVerificationScreen(
                            actions: [
                              EmailVerifiedAction(() {
                                if (_timer.isActive) {
                                  debugPrint("Timer cancelled");
                                  _timer.cancel();
                                }
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MultiFactorAuth(
                                      route: true,
                                    ),
                                  ),
                                );
                              }),
                              AuthCancelledAction((context) {
                                FirebaseUIAuth.signOut(context: context);
                                Navigator.pushReplacementNamed(context, '/');
                              }),
                            ],
                          );
                        }
                      } else {
                        return const Text(
                            'Error occurred while getting enrolled factors');
                      }
                    } else {
                      return Container(
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LoadingWidget(),
                            SizedBox(height: 16),
                            Text(
                              'Logging securely into end to end encrypted system...',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              } else if (snapshot.hasError) {
                return const Text('Error occurred');
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingWidget(),
                      SizedBox(height: 16),
                      Text(
                        'Logging securely into end to end encrypted system...',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
