import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/auth_repository.dart';
import '../domain/app_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider = StreamProvider<User?>((ref) {
  if (!ref.watch(firebaseConfiguredProvider)) return Stream.value(null);
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authStateProvider).asData?.value,
);

final profileProvider = StreamProvider<AppProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).watchProfile(user.uid);
});
