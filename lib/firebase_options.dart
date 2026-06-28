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
      default:
        throw UnsupportedError('Not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlTUG--XTcow4DoU5IaNvovUf0qhgs3EU',
    appId: '1:800756316354:android:e54daf4128508f15de635b',
    messagingSenderId: '800756316354',
    projectId: 'gold-reward-371d3',
    storageBucket: 'gold-reward-371d3.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDlTUG--XTcow4DoU5IaNvovUf0qhgs3EU',
    appId: '1:800756316354:android:e54daf4128508f15de635b',
    messagingSenderId: '800756316354',
    projectId: 'gold-reward-371d3',
    storageBucket: 'gold-reward-371d3.firebasestorage.app',
    authDomain: 'gold-reward-371d3.firebaseapp.com',
  );
}
