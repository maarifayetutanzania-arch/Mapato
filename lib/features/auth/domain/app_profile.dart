import 'package:cloud_firestore/cloud_firestore.dart';

class AppProfile {
  const AppProfile({
    required this.displayName,
    required this.email,
    required this.currency,
    required this.language,
    required this.monthlyIncomeMinor,
    required this.financialGoal,
    this.monthlyBudgetMinor = 0,
    this.setupComplete = true,
  });

  final String displayName;
  final String email;
  final String currency;
  final String language;
  final int monthlyIncomeMinor;
  final String financialGoal;
  final int monthlyBudgetMinor;
  final bool setupComplete;

  factory AppProfile.fromMap(Map<String, dynamic> data) => AppProfile(
        displayName: data['displayName'] as String? ?? '',
        email: data['email'] as String? ?? '',
        currency: data['currency'] as String? ?? 'TZS',
        language: data['language'] as String? ?? 'en',
        monthlyIncomeMinor: (data['monthlyIncomeMinor'] as num?)?.toInt() ?? 0,
        financialGoal: data['financialGoal'] as String? ?? '',
        monthlyBudgetMinor: (data['monthlyBudgetMinor'] as num?)?.toInt() ?? 0,
        setupComplete: data['setupComplete'] as bool? ?? true,
      );

  Map<String, Object?> toMap() => {
        'displayName': displayName.trim(),
        'email': email.trim().toLowerCase(),
        'currency': currency,
        'language': language,
        'monthlyIncomeMinor': monthlyIncomeMinor,
        'monthlyBudgetMinor': monthlyBudgetMinor,
        'financialGoal': financialGoal,
        'setupComplete': setupComplete,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
