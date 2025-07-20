// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBTNi_O9nYCmZgL5QDVroZ4KAdwbQyYjK0',
    authDomain: 'campusclash-b1982.firebaseapp.com',
    projectId: 'campusclash-b1982',
    storageBucket: 'campusclash-b1982.appspot.com',
    messagingSenderId: '1080075166737',
    appId: '1:1080075166737:web:3133b757804cb70caf3db0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBTNi_O9nYCmZgL5QDVroZ4KAdwbQyYjK0',
    appId: '1:1080075166737:web:3133b757804cb70caf3db0',
    messagingSenderId: '1080075166737',
    projectId: 'campusclash-b1982',
    storageBucket: 'campusclash-b1982.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBTNi_O9nYCmZgL5QDVroZ4KAdwbQyYjK0',
    appId: '1:1080075166737:web:3133b757804cb70caf3db0',
    messagingSenderId: '1080075166737',
    projectId: 'campusclash-b1982',
    storageBucket: 'campusclash-b1982.appspot.com',
    iosClientId: '',
    iosBundleId: 'com.example.campusEventChecker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBTNi_O9nYCmZgL5QDVroZ4KAdwbQyYjK0',
    appId: '1:1080075166737:web:3133b757804cb70caf3db0',
    messagingSenderId: '1080075166737',
    projectId: 'campusclash-b1982',
    storageBucket: 'campusclash-b1982.appspot.com',
  );
}
