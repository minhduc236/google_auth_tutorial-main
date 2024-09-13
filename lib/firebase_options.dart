import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyD-1-ys-SDL4rB6-fSq0vf9a_StrcsjxOw",
    authDomain: "todo-92bae.firebaseapp.com",
    databaseURL: "https://todo-92bae-default-rtdb.firebaseio.com",
    projectId: "todo-92bae",
    storageBucket: "todo-92bae.appspot.com",
    messagingSenderId: "991561743550",
    appId: "1:991561743550:web:9ac2a3219fe089274d72ef",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyD-1-ys-SDL4rB6-fSq0vf9a_StrcsjxOw",
    authDomain: "todo-92bae.firebaseapp.com",
    databaseURL: "https://todo-92bae-default-rtdb.firebaseio.com",
    projectId: "todo-92bae",
    storageBucket: "todo-92bae.appspot.com",
    messagingSenderId: "991561743550",
    appId: "1:991561743550:android:9ac2a3219fe089274d72ef",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyD-1-ys-SDL4rB6-fSq0vf9a_StrcsjxOw",
    authDomain: "todo-92bae.firebaseapp.com",
    databaseURL: "https://todo-92bae-default-rtdb.firebaseio.com",
    projectId: "todo-92bae",
    storageBucket: "todo-92bae.appspot.com",
    messagingSenderId: "991561743550",
    appId: "1:991561743550:ios:9ac2a3219fe089274d72ef",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyD-1-ys-SDL4rB6-fSq0vf9a_StrcsjxOw",
    authDomain: "todo-92bae.firebaseapp.com",
    databaseURL: "https://todo-92bae-default-rtdb.firebaseio.com",
    projectId: "todo-92bae",
    storageBucket: "todo-92bae.appspot.com",
    messagingSenderId: "991561743550",
    appId: "1:991561743550:macos:9ac2a3219fe089274d72ef",
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "AIzaSyD-1-ys-SDL4rB6-fSq0vf9a_StrcsjxOw",
    authDomain: "todo-92bae.firebaseapp.com",
    databaseURL: "https://todo-92bae-default-rtdb.firebaseio.com",
    projectId: "todo-92bae",
    storageBucket: "todo-92bae.appspot.com",
    messagingSenderId: "991561743550",
    appId: "1:991561743550:windows:9ac2a3219fe089274d72ef",
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: "AIzaSyD-1-ys-SDL4rB6-fSq0vf9a_StrcsjxOw",
    authDomain: "todo-92bae.firebaseapp.com",
    databaseURL: "https://todo-92bae-default-rtdb.firebaseio.com",
    projectId: "todo-92bae",
    storageBucket: "todo-92bae.appspot.com",
    messagingSenderId: "991561743550",
    appId: "1:991561743550:linux:9ac2a3219fe089274d72ef",
  );
}
