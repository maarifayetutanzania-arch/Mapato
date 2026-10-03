import 'package:intl/intl.dart';

abstract final class Money {
  static const maxMajorAmount = 1000000000000;
  static const _minorDigits = <String, int>{'TZS': 0, 'JPY': 0, 'USD': 2, 'KES': 2};

  static int minorDigits(String currency) => _minorDigits[currency] ?? 2;

  static int? parseMinor(String input, String currency) {
    final normalized = input.replaceAll(',', '').replaceAll(' ', '').trim();
    final digits = minorDigits(currency);
    final pattern = digits == 0
        ? RegExp(r'^\d+$')
        : RegExp(r'^\d+(?:\.\d{1,' + digits.toString() + r'})?$');
    if (!pattern.hasMatch(normalized)) return null;
    final parts = normalized.split('.');
    final major = BigInt.tryParse(parts.first);
    if (major == null || major > BigInt.from(maxMajorAmount)) return null;
    if (digits == 0) return major.toInt();
    final fraction = parts.length == 1 ? '' : parts[1];
    final scaledFraction = fraction.padRight(digits, '0');
    final value = major * BigInt.from(10).pow(digits) +
        BigInt.tryParse(scaledFraction.isEmpty ? '0' : scaledFraction)!;
    final maximum = BigInt.from(maxMajorAmount) * BigInt.from(10).pow(digits);
    return value > maximum ? null : value.toInt();
  }

  static String formatMinor(int amountMinor, String currency, String locale) {
    final digits = minorDigits(currency);
    final majorAmount = amountMinor / BigInt.from(10).pow(digits).toInt();
    return NumberFormat.currency(
      locale: locale,
      name: currency,
      symbol: currency,
      decimalDigits: digits,
    ).format(majorAmount);
  }

  static String decimalInput(int amountMinor, String currency) {
    final digits = minorDigits(currency);
    final divisor = BigInt.from(10).pow(digits);
    final amount = BigInt.from(amountMinor);
    final major = amount ~/ divisor;
    if (digits == 0) return major.toString();
    final fraction = (amount % divisor).toString().padLeft(digits, '0');
    return '$major.$fraction';
  }
}
