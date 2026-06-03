import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase config for project [safe-a67e3].
class DefaultFirebaseOptions {
  static const String databaseUrl =
      'https://safe-a67e3-default-rtdb.firebaseio.com';

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
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAquwLiBkBsKx3Izzkagiuj0Ogmo8tzyQ8',
    appId: '1:402309077340:android:7f68eb69516366a436c999',
    messagingSenderId: '402309077340',
    projectId: 'safe-a67e3',
    authDomain: 'safe-a67e3.firebaseapp.com',
    databaseURL: databaseUrl,
    storageBucket: 'safe-a67e3.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAquwLiBkBsKx3Izzkagiuj0Ogmo8tzyQ8',
    appId: '1:402309077340:android:7f68eb69516366a436c999',
    messagingSenderId: '402309077340',
    projectId: 'safe-a67e3',
    databaseURL: databaseUrl,
    storageBucket: 'safe-a67e3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAquwLiBkBsKx3Izzkagiuj0Ogmo8tzyQ8',
    appId: '1:402309077340:android:7f68eb69516366a436c999',
    messagingSenderId: '402309077340',
    projectId: 'safe-a67e3',
    databaseURL: databaseUrl,
    storageBucket: 'safe-a67e3.appspot.com',
    iosBundleId: 'com.safe_me.safe_me1',
  );
}
