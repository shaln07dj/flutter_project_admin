import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:local_session_timeout/local_session_timeout.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Models/app_state.dart';
import 'package:pauzible_app/api/skyflow/widgets/app.dart';
import 'package:pauzible_app/redux/store.dart';
import 'package:pauzible_app/screens/admin_view.dart';
import 'package:pauzible_app/screens/auth_gate.dart';
import 'package:pauzible_app/screens/file_view.dart';
import 'package:pauzible_app/widgets/logout.dart';

void main() async {
  bool isProd = const bool.fromEnvironment('prod', defaultValue: false);

  String envFileName = isProd ? '.env.prod' : '.env.dev';
  await dotenv.load(fileName: envFileName);

  WidgetsFlutterBinding.ensureInitialized();
  await initSharedPreferences();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "${dotenv.env['API_KEY']}",
          appId: "${dotenv.env['APP_ID']}",
          messagingSenderId: "${dotenv.env['Messaging_Sender_ID']}",
          projectId: "${dotenv.env['PROJECT_ID']}"));
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();
// final _navigatorKey = GlobalKey<NavigatorState>();
NavigatorState get navigator => navigatorKey.currentState!;

/// Make this stream available throughout the widget tree with with any state management library
/// like bloc, provider, GetX, ..
final sessionStateStream = StreamController<SessionState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionConfig = SessionConfig(
      invalidateSessionForAppLostFocus: const Duration(minutes: 10),
      invalidateSessionForUserInactivity: const Duration(minutes: 10),
    );

    sessionConfig.stream.listen((SessionTimeoutState timeoutEvent) {
      sessionStateStream.add(SessionState.stopListening);
      if (timeoutEvent == SessionTimeoutState.userInactivityTimeout) {
        debugPrint('Inactivity');
        SignOut();
      } else if (timeoutEvent == SessionTimeoutState.appFocusTimeout) {
        debugPrint('Focus Out');
        SignOut();
      }
    });
    return SessionTimeoutManager(
      // userActivityDebounceDuration: const Duration(seconds: 1),
      sessionConfig: sessionConfig,
      sessionStateStream: sessionStateStream.stream,
      child: StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Pauzible Dashboard',
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF0E5EB6)),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/login': (context) => const AuthGate(),
            '/admin_view': (context) => admin_view(
                  route: true,
                ),
            '/file_view': (context) => file_view(),
          },
          home: const App(),
        ),
      ),
    );
  }
}
