// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mapato_binafsi/features/auth/presentation/auth_screens.dart';
import 'package:mapato_binafsi/l10n/app_localizations.dart';

void main() {
  testWidgets('Firebase setup screen explains the required configuration', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FirebaseSetupScreen(),
      ),
    );
    expect(find.text('Connect your Firebase project'), findsOneWidget);
    expect(find.text('Run: flutterfire configure'), findsOneWidget);
  });
}
