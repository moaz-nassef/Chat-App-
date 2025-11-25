import 'package:authentication_app/firebase_options.dart';
import 'package:authentication_app/pages/pages_chat.dart';
import 'package:authentication_app/pages/login.dart';
import 'package:authentication_app/pages/sigunp.dart';
import 'package:authentication_app/pages/start.dart';
import 'package:authentication_app/pages/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/welcome",
      routes: {
        '/welcome': (context) => const Welcome(),
        '/Start': (context) => const Start(),
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        "/chat": (context) => const Chat(),
      },
    );
  }
}
