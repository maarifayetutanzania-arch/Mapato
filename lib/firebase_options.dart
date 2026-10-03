import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.generated.dart' as generated;

abstract final class DefaultFirebaseOptions {
  static bool get isConfigured {
    try {
      final options = currentPlatform;
      return options.projectId.isNotEmpty &&
          options.projectId != 'UNCONFIGURED' &&
          options.apiKey.isNotEmpty &&
          options.apiKey != 'UNCONFIGURED' &&
          options.appId.isNotEmpty &&
          options.appId != 'UNCONFIGURED';
    } on UnsupportedError {
      return false;
    }
  }

  static FirebaseOptions get currentPlatform =>
      generated.DefaultFirebaseOptions.currentPlatform;
}
