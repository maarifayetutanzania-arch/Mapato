import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FriendlyError {
  const FriendlyError._();

  static String message(Object error) {
    if (error is FirebaseAuthException && error.code == 'invalid-email') {
      return 'emailInvalid';
    }
    if (error is FirebaseFunctionsException &&
        (error.code == 'invalid-argument' || error.code == 'permission-denied')) {
      return 'otpInvalid';
    }
    if (error is FirebaseException &&
        (error.code == 'unavailable' || error.code == 'network-request-failed')) {
      return 'networkError';
    }
    return 'genericError';
  }
}
