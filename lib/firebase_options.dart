// TODO Implement this library.// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyBZPcOhovZil1VUxR7G-ZyS9HQ3ejjhtLI',
    appId: '1:508448746072:web:977302f1255af7e9df382d',
    messagingSenderId: '508448746072',
    projectId: 'spauthentication-ecf78',
    authDomain: 'spauthentication-ecf78.firebaseapp.com',
    storageBucket: 'spauthentication-ecf78.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9M6JmmPb3CjTpImkNAs7_rgLmm440syc',
    appId: '1:508448746072:android:09f63d2da623c7f5df382d',
    messagingSenderId: '508448746072',
    projectId: 'spauthentication-ecf78',
    storageBucket: 'spauthentication-ecf78.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJto1qywEEVUvijq1PfdVCtXoTbCP94ns',
    appId: '1:508448746072:ios:31a72866f388293bdf382d',
    messagingSenderId: '508448746072',
    projectId: 'spauthentication-ecf78',
    storageBucket: 'spauthentication-ecf78.firebasestorage.app',
    iosBundleId: 'com.example.smartproductiveApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAJto1qywEEVUvijq1PfdVCtXoTbCP94ns',
    appId: '1:508448746072:ios:31a72866f388293bdf382d',
    messagingSenderId: '508448746072',
    projectId: 'spauthentication-ecf78',
    storageBucket: 'spauthentication-ecf78.firebasestorage.app',
    iosBundleId: 'com.example.smartproductiveApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBZPcOhovZil1VUxR7G-ZyS9HQ3ejjhtLI',
    appId: '1:508448746072:web:9222819a6b9790badf382d',
    messagingSenderId: '508448746072',
    projectId: 'spauthentication-ecf78',
    authDomain: 'spauthentication-ecf78.firebaseapp.com',
    storageBucket: 'spauthentication-ecf78.firebasestorage.app',
  );
}
