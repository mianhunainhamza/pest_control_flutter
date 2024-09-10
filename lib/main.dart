import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pest_control_flutter/screens/admin/home_editor_admin.dart';
import 'package:pest_control_flutter/screens/home_page_editor.dart';
import 'package:pest_control_flutter/screens/on_board/start.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/notifications.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Initialize Firebase

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool("loggedIn") ?? false;
    bool isAdmin = prefs.getBool("isAdmin") ?? false;

    runApp(MyApp(isLoggedIn: isLoggedIn, isAdmin: isAdmin));
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isAdmin;
  const MyApp({required this.isLoggedIn, required this.isAdmin, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: FutureBuilder(
        future: checkLoginStatus(),
        builder: (context, loginSnapshot) {
            return FutureBuilder(
              future: checkLoginStatus(),
              builder: (context, roleSnapshot) {
                  if (isLoggedIn) {
                    if (isAdmin) {
                      return const MyHomePageAdmin();
                    } else {
                      return const MyHomePage();
                    }
                  } else {
                    return const StartPage();
                  }
              },
            );
          }
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<bool> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("loggedIn") ?? false;
  }
}
