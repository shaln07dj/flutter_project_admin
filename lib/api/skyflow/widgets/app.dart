import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pauzible_app/screens/login_home.dart';

class App extends StatefulWidget {
  const App({Key? key});

  @override
  State<App> createState() {
    return _App();
  }
}

class _App extends State<App> {
  var channel = const MethodChannel("CHANNEL");
  List<String> itemList = [];
  List<Widget> widgetList = [];

  void showToast() {
    channel.invokeMethod('showToast', {'message': 'Hello From Pauzible'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 0,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const LoginHome(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
