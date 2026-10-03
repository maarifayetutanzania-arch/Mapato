import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('SharedPreferences has not been initialized.'),
);

final firebaseConfiguredProvider = Provider<bool>((ref) => false);
final analyticsProvider = Provider<FirebaseAnalytics?>((ref) => null);

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  static const _themeKey = 'preferred_theme_mode';

  @override
  ThemeMode build() =>
      switch (ref.read(sharedPreferencesProvider).getString(_themeKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await ref.read(sharedPreferencesProvider).setString(_themeKey, value);
    state = mode;
  }
}

class LocaleController extends Notifier<Locale> {
  static const _languageKey = 'preferred_language';

  @override
  Locale build() {
    final code = ref.read(sharedPreferencesProvider).getString(_languageKey);
    return Locale(code == 'sw' ? 'sw' : 'en');
  }

  Future<void> setLanguage(String code) async {
    if (code != 'en' && code != 'sw') return;
    await ref.read(sharedPreferencesProvider).setString(_languageKey, code);
    state = Locale(code);
  }
}
