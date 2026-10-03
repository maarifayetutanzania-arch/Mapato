import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class DefaultFirebaseOptions {
  static const _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'UNCONFIGURED',
  );
  static const _senderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: 'UNCONFIGURED',
  );
  static const _apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'UNCONFIGURED',
  );
  static const _webAppId = String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
    defaultValue: 'UNCONFIGURED',
  );
  static const _androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
    defaultValue: 'UNCONFIGURED',
  );
  static const _iosAppId = String.fromEnvironment(
    'FIREBASE_IOS_APP_ID',
    defaultValue: 'UNCONFIGURED',
  );
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _databaseURL = String.fromEnvironment('FIREBASE_DATABASE_URL');
  static const _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );

  static const web = FirebaseOptions(
    apiKey: _apiKey,
    appId: _webAppId,
    messagingSenderId: _senderId,
    projectId: _projectId,
    authDomain: _authDomain,
    databaseURL: _databaseURL,
    storageBucket: _storageBucket,
  );

  static const android = FirebaseOptions(
    apiKey: _apiKey,
    appId: _androidAppId,
    messagingSenderId: _senderId,
    projectId: _projectId,
    databaseURL: _databaseURL,
    storageBucket: _storageBucket,
  );

  static const ios = FirebaseOptions(
    apiKey: _apiKey,
    appId: _iosAppId,
    messagingSenderId: _senderId,
    projectId: _projectId,
    databaseURL: _databaseURL,
    storageBucket: _storageBucket,
    iosBundleId: 'tz.co.mapato.mapatoBinafsi',
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      _ => throw UnsupportedError(
        'Mapato Binafsi supports Android, iOS, and web.',
      ),
    };
  }
}
