// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAbpkqNM5o9tHvEJD8eRDWDrchKiyAMPNU',
    appId: '1:8175006174:web:0dce1e75db9c87a7b1ed4f',
    messagingSenderId: '8175006174',
    projectId: 'nexus-v03',
    authDomain: 'nexus-v03.firebaseapp.com',
    storageBucket: 'nexus-v03.appspot.com',
    measurementId: 'G-S3SS9FYFXY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA2X6-FGF2xISeCkGD1xzKFg9r6VIjJH4g',
    appId: '1:8175006174:android:39bb96e7a6a3c340b1ed4f',
    messagingSenderId: '8175006174',
    projectId: 'nexus-v03',
    storageBucket: 'nexus-v03.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAg4IEV_CsAfoEilUX5TyWJcvgSTscRK24',
    appId: '1:8175006174:ios:9aa64ba808c8ffb1b1ed4f',
    messagingSenderId: '8175006174',
    projectId: 'nexus-v03',
    storageBucket: 'nexus-v03.appspot.com',
    iosClientId: '8175006174-mb4qdq1qr5sdj446vs9rr5sec1396tjr.apps.googleusercontent.com',
    iosBundleId: 'com.nexuslinkid.linkup',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAg4IEV_CsAfoEilUX5TyWJcvgSTscRK24',
    appId: '1:8175006174:ios:523d878f02dae92bb1ed4f',
    messagingSenderId: '8175006174',
    projectId: 'nexus-v03',
    storageBucket: 'nexus-v03.appspot.com',
    iosClientId: '8175006174-0nq29bkhi2iq7brnja2kcvdnotddhb2r.apps.googleusercontent.com',
    iosBundleId: 'com.example.nexus.RunnerTests',
  );
}
