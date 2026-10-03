import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/app_profile.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'africa-south1'),
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> requestEmailCode(String email, {String language = 'en'}) async {
    final normalized = email.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalized)) {
      throw const AuthInputException('invalid-email');
    }
    await _functions.httpsCallable('requestEmailCode').call<void>({
      'email': normalized,
      'language': language == 'sw' ? 'sw' : 'en',
    });
  }

  Future<UserCredential> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      throw const AuthInputException('invalid-code');
    }
    final result = await _functions
        .httpsCallable('verifyEmailCode')
        .call<Map<String, dynamic>>({'email': normalized, 'code': code});
    final token = result.data['customToken'] as String?;
    if (token == null || token.isEmpty) {
      throw const AuthInputException('invalid-code');
    }
    return _auth.signInWithCustomToken(token);
  }

  Future<AppProfile?> getProfile(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return AppProfile.fromMap(data);
  }

  Stream<AppProfile?> watchProfile(String uid) =>
      _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
        final data = snapshot.data();
        return data == null ? null : AppProfile.fromMap(data);
      });

  Future<void> saveProfile(AppProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthInputException('not-authenticated');
    if (profile.displayName.trim().isEmpty ||
        profile.monthlyIncomeMinor < 0 ||
        profile.monthlyBudgetMinor < 0 ||
        profile.financialGoal.trim().isEmpty) {
      throw const AuthInputException('invalid-profile');
    }
    final reference = _firestore.collection('users').doc(user.uid);
    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(reference);
      transaction.set(reference, {
        ...profile.toMap(),
        'email': user.email ?? profile.email,
        if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> signOut() => _auth.signOut();
}

class AuthInputException implements Exception {
  const AuthInputException(this.code);
  final String code;
}
