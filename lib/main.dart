// ignore_for_file: unused_import, depend_on_referenced_packages

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nexus/auth/auth.dart';
import 'package:nexus/auth/login_or_register.dart';
import 'package:nexus/pages/ad_page.dart';
import 'package:nexus/pages/personal_page.dart';
import 'package:nexus/services/ad_service.dart';
import 'package:nexus/services/user_profile.dart';
import 'package:nexus/theme/dark_theme.dart';
import 'package:nexus/theme/light_theme.dart';
import 'pages/login_page.dart';
import 'firebase_options.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:page_transition/page_transition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

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
        home: BlocProvider(
          // Provide UserBloc here
          create: (context) => UserBloc(),
          child: AnimatedSplashScreen(
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
            nextScreen: AdPlatformSelection(), // Directly navigate here
          ),
        ),
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
      ),
    );
  }
}
