import 'package:flutter/material.dart';

import '../l10n/context_localizations.dart';

String categoryLabel(BuildContext context, String id) {
  final l10n = context.l10n;
  return switch (id) {
    'salary' => l10n.salary,
    'business' => l10n.business,
    'freelance' => l10n.freelance,
    'investment' => l10n.investment,
    'other_income' => l10n.otherIncome,
    'food' => l10n.food,
    'transport' => l10n.transport,
    'rent' => l10n.rent,
    'bills' => l10n.bills,
    'shopping' => l10n.shopping,
    'health' => l10n.health,
    'education' => l10n.education,
    'entertainment' => l10n.entertainment,
    'family' => l10n.family,
    'other_expense' => l10n.otherExpense,
    _ => l10n.categoryOther,
  };
}

List<(String, String)> transactionCategories(BuildContext context, bool income) => income
    ? [
        ('salary', categoryLabel(context, 'salary')),
        ('business', categoryLabel(context, 'business')),
        ('freelance', categoryLabel(context, 'freelance')),
        ('investment', categoryLabel(context, 'investment')),
        ('other_income', categoryLabel(context, 'other_income')),
      ]
    : [
        ('food', categoryLabel(context, 'food')),
        ('transport', categoryLabel(context, 'transport')),
        ('rent', categoryLabel(context, 'rent')),
        ('bills', categoryLabel(context, 'bills')),
        ('shopping', categoryLabel(context, 'shopping')),
        ('health', categoryLabel(context, 'health')),
        ('education', categoryLabel(context, 'education')),
        ('entertainment', categoryLabel(context, 'entertainment')),
        ('family', categoryLabel(context, 'family')),
        ('other_expense', categoryLabel(context, 'other_expense')),
      ];

IconData categoryIcon(String id) => switch (id) {
      'salary' => Icons.work_outline,
      'business' => Icons.storefront_outlined,
      'freelance' => Icons.laptop_mac,
      'investment' => Icons.trending_up,
      'food' => Icons.restaurant_outlined,
      'transport' => Icons.directions_bus_outlined,
      'rent' => Icons.home_outlined,
      'bills' => Icons.receipt_long_outlined,
      'shopping' => Icons.shopping_bag_outlined,
      'health' => Icons.health_and_safety_outlined,
      'education' => Icons.school_outlined,
      'entertainment' => Icons.movie_outlined,
      'family' => Icons.family_restroom,
      _ => Icons.category_outlined,
    };
