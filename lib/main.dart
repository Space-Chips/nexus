// ignore_for_file: unused_import, depend_on_referenced_packages

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nexus/auth/auth.dart';
import 'package:nexus/auth/login_or_register.dart';
import 'package:nexus/theme/dark_theme.dart';
import 'package:nexus/theme/light_theme.dart';
import 'pages/login_page.dart';
import 'firebase_options.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:page_transition/page_transition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: lightTheme,
      dark: darkTheme,
      initial: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MaterialApp(
        title: "NEXUS",
        home: AnimatedSplashScreen(
          duration: 3000,
          backgroundColor: Colors.white,
          splashTransition: SplashTransition.fadeTransition,
          pageTransitionType: PageTransitionType.fade,
          splash: Text(
            "N E X U S",
            style: TextStyle(
              fontSize: 50,
              color: Colors.grey[900],
            ),
          ),
          nextScreen: const AuthPage(),
        ),
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
      ),
    );
  }
}
