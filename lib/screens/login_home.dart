import 'package:flutter/material.dart';
import 'package:pauzible_app/main.dart';
import 'package:pauzible_app/screens/auth_gate.dart';

class LoginHome extends StatefulWidget {
  const LoginHome({super.key});

  @override
  _LoginHomeState createState() => _LoginHomeState();
}

class _LoginHomeState extends State<LoginHome> {
  final TrackingScrollController _trackingScrollController =
      TrackingScrollController();

  var screenWidth = 0.00;
  double responsiveWidth = 0.0;

  @override
  void dispose() {
    _trackingScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      screenWidth = (MediaQuery.of(context).size.width);
    });
    if (screenWidth >= 1200) {
      // Large desktop screen
      responsiveWidth = (MediaQuery.of(context).size.width) / 2;
    } else if (screenWidth >= 800) {
      // Medium desktop screen
      responsiveWidth = 350;
    } else {
      // Small desktop or mobile screen
      responsiveWidth = 200;
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: [
          SizedBox(
            width: screenWidth,
            height: MediaQuery.of(context).size.height,
            child: const AuthGate(),
          ),
        ],
      ),
    );
  }
}
