// File generated by FlutterFire CLI.
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
    apiKey: 'AIzaSyDqQxuhz8v3KmxQ2J6Ot1ntDWEbbVBbBS0',
    appId: '1:926840923325:web:4368f56b4bb394482c83d4',
    messagingSenderId: '926840923325',
    projectId: 'smartchat-ba3ae',
    authDomain: 'smartchat-ba3ae.firebaseapp.com',
    storageBucket: 'smartchat-ba3ae.firebasestorage.app',
    measurementId: 'G-81JVPB6ZHC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAKMlaTzsT5TwQyReYcBa-zUZforbUi-Ds',
    appId: '1:926840923325:android:98760d7879d6c37d2c83d4',
    messagingSenderId: '926840923325',
    projectId: 'smartchat-ba3ae',
    storageBucket: 'smartchat-ba3ae.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA5liGd4n65y0OgSnzCvKHW3u7xaAOiUWs',
    appId: '1:926840923325:ios:80cb4c7959e03b3b2c83d4',
    messagingSenderId: '926840923325',
    projectId: 'smartchat-ba3ae',
    storageBucket: 'smartchat-ba3ae.firebasestorage.app',
    androidClientId: '926840923325-64csqfcj4kf9dfsoq84thr8re0qnlstk.apps.googleusercontent.com',
    iosClientId: '926840923325-kknjp2ck36at90r4r9mupmcjdcjt4i72.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartChat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA5liGd4n65y0OgSnzCvKHW3u7xaAOiUWs',
    appId: '1:926840923325:ios:80cb4c7959e03b3b2c83d4',
    messagingSenderId: '926840923325',
    projectId: 'smartchat-ba3ae',
    storageBucket: 'smartchat-ba3ae.firebasestorage.app',
    androidClientId: '926840923325-64csqfcj4kf9dfsoq84thr8re0qnlstk.apps.googleusercontent.com',
    iosClientId: '926840923325-kknjp2ck36at90r4r9mupmcjdcjt4i72.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartChat',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDqQxuhz8v3KmxQ2J6Ot1ntDWEbbVBbBS0',
    appId: '1:926840923325:web:65b5a599e9c3c0712c83d4',
    messagingSenderId: '926840923325',
    projectId: 'smartchat-ba3ae',
    authDomain: 'smartchat-ba3ae.firebaseapp.com',
    storageBucket: 'smartchat-ba3ae.firebasestorage.app',
    measurementId: 'G-3HDTM00YKX',
  );

}