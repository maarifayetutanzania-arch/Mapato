import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  var firebaseConfigured = false;
  FirebaseAnalytics? analytics;

  if (DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseConfigured = true;
      if (kReleaseMode) {
        await FirebaseAppCheck.instance.activate(
          providerAndroid: const AndroidPlayIntegrityProvider(),
          providerApple: const AppleAppAttestWithDeviceCheckFallbackProvider(),
          providerWeb: ReCaptchaV3Provider(
            const String.fromEnvironment('FIREBASE_APPCHECK_RECAPTCHA_KEY'),
          ),
        );
      } else {
        const debugToken = String.fromEnvironment(
          'FIREBASE_APPCHECK_DEBUG_TOKEN',
        );
        await FirebaseAppCheck.instance.activate(
          providerAndroid: const AndroidDebugProvider(debugToken: debugToken),
          providerApple: const AppleDebugProvider(debugToken: debugToken),
          providerWeb: WebDebugProvider(
            debugToken: debugToken.isEmpty ? null : debugToken,
          ),
        );
      }
      analytics = FirebaseAnalytics.instance;
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    } on FirebaseException catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'Firebase initialization',
        ),
      );
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        firebaseConfiguredProvider.overrideWithValue(firebaseConfigured),
        analyticsProvider.overrideWithValue(analytics),
      ],
      child: const MapatoApp(),
    ),
  );
}
