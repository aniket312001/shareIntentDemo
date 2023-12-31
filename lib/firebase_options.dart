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
    apiKey: 'AIzaSyAtCP_BJzanJI1h-DK8thFmc_qtEMEzCiQ',
    appId: '1:729866818018:web:7c4106102ea197f1fce9bb',
    messagingSenderId: '729866818018',
    projectId: 'sno-project',
    authDomain: 'sno-project.firebaseapp.com',
    databaseURL: 'https://sno-project-default-rtdb.firebaseio.com',
    storageBucket: 'sno-project.appspot.com',
    measurementId: 'G-7VKNWMBJ5J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSgTZB6RDk39DZE23rwfS_7eF--YXSyik',
    appId: '1:729866818018:android:cce559e2a90b717bfce9bb',
    messagingSenderId: '729866818018',
    projectId: 'sno-project',
    databaseURL: 'https://sno-project-default-rtdb.firebaseio.com',
    storageBucket: 'sno-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDS51GSmcCFS7FlvLjYVkfhzrzSRryRJGw',
    appId: '1:729866818018:ios:8fa58a1065bd3662fce9bb',
    messagingSenderId: '729866818018',
    projectId: 'sno-project',
    databaseURL: 'https://sno-project-default-rtdb.firebaseio.com',
    storageBucket: 'sno-project.appspot.com',
    iosClientId:
        '729866818018-v3tamr7tpc1eajqpminl9857c47f2ng3.apps.googleusercontent.com',
    iosBundleId: 'com.example.snoBizApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDS51GSmcCFS7FlvLjYVkfhzrzSRryRJGw',
    appId: '1:729866818018:ios:fab7035de4e1b073fce9bb',
    messagingSenderId: '729866818018',
    projectId: 'sno-project',
    databaseURL: 'https://sno-project-default-rtdb.firebaseio.com',
    storageBucket: 'sno-project.appspot.com',
    iosClientId:
        '729866818018-bm42o36r51dijc6746oiqj7qb93ouohd.apps.googleusercontent.com',
    iosBundleId: 'com.example.snoBizApp.RunnerTests',
  );
}
