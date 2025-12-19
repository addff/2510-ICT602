import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyA8hTsQfZSAK3UadvUEt9F9oz4mt7PVdps',
    appId: '1:689937074518:web:aea13940391b7adda62ef7',
    messagingSenderId: '689937074518',
    projectId: 'assignment-indi-ict602',
    authDomain: 'assignment-indi-ict602.firebaseapp.com',
    storageBucket: 'assignment-indi-ict602.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyAndroidKey',
    appId: '1:123456789:android:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'ict602-grade-app',
    storageBucket: 'ict602-grade-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyIOSKey',
    appId: '1:123456789:ios:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'ict602-grade-app',
    storageBucket: 'ict602-grade-app.appspot.com',
    iosBundleId: 'com.example.ict602app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyMacOSKey',
    appId: '1:123456789:macos:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'ict602-grade-app',
    storageBucket: 'ict602-grade-app.appspot.com',
    iosBundleId: 'com.example.ict602app.macos',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDummyWindowsKey',
    appId: '1:123456789:windows:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'ict602-grade-app',
    storageBucket: 'ict602-grade-app.appspot.com',
  );
}
