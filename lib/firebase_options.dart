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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSlG5gwt8BNYgTWSoykgYkFK1wnZ3AaOw',
    appId: '1:654349620102:android:2e90a5c7ee477784401207',
    messagingSenderId: '654349620102',
    projectId: 'flutterapp-b1ba6',
    storageBucket: 'flutterapp-b1ba6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAIgIcd9YwaxLttQLJsIb7bbW1w9FKjOSg',
    appId: '1:654349620102:ios:3eb64c1c157a2831401207',
    messagingSenderId: '654349620102',
    projectId: 'flutterapp-b1ba6',
    storageBucket: 'flutterapp-b1ba6.appspot.com',
    androidClientId: '654349620102-h80uq9nhd07i98mh0ip714ouljfka3do.apps.googleusercontent.com',
    iosClientId: '654349620102-ojss08aq83pg0qi9eqm6801e7vviivb3.apps.googleusercontent.com',
    iosBundleId: 'com.example.myApp',
  );
}