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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDiIHE9gi8P_LptvmwNVAUuPdcZvaRO0II',
    appId: '1:333961698477:web:4b278b1196502fc1103a24',
    messagingSenderId: '333961698477',
    projectId: 'skill-share-429e9',
    authDomain: 'skill-share-429e9.firebaseapp.com',
    storageBucket: 'skill-share-429e9.appspot.com',
    measurementId: 'G-7EV4XD980M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHsJH6RiJz0VkgaHyiGz-F-NjL6qOr2KM',
    appId: '1:333961698477:android:a31a1f10f88d7267103a24',
    messagingSenderId: '333961698477',
    projectId: 'skill-share-429e9',
    storageBucket: 'skill-share-429e9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJ0oMhSnkKphV68KXpzm_Eidw1ZBkWi10',
    appId: '1:333961698477:ios:d52954048d4c31de103a24',
    messagingSenderId: '333961698477',
    projectId: 'skill-share-429e9',
    storageBucket: 'skill-share-429e9.appspot.com',
    iosClientId: '333961698477-4rnjcbju85p8ctr51hb9datn3cj1ec0h.apps.googleusercontent.com',
    iosBundleId: 'com.example.skillShare',
  );
}
