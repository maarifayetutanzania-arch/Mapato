import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapato_binafsi/features/auth/presentation/auth_screens.dart';
import 'package:mapato_binafsi/l10n/app_localizations.dart';

void main() {
  testWidgets('Email login validates address before send action', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EmailLoginScreen(),
        ),
      ),
    );
    await tester.tap(find.text('Send code'));
    await tester.pump();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });
}
