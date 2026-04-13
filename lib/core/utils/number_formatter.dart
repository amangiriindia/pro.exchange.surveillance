import 'package:intl/intl.dart';

class NumberFormatter {
  NumberFormatter._();
  static String formatWithCommas(num number) {
    final formatter = NumberFormat('#,##,###');
    return formatter.format(number);
  }

  static String formatPrice(num price) {
    final formatter = NumberFormat('#,##,##0.00');
    return formatter.format(price);
  }

  static String formatPriceWithPrecision(num price, {int decimalPlaces = 2}) {
    final decimals = decimalPlaces < 0 ? 0 : decimalPlaces;
    final pattern = decimals == 0 ? '#,##,##0' : '#,##,##0.${'#' * decimals}';
    final formatter = NumberFormat(pattern);
    return formatter.format(price);
  }

  static String formatPercentage(num percentage) {
    return '${(percentage).toStringAsFixed(2)}%';
  }

  static String formatQuantity(int quantity) {
    final formatter = NumberFormat('#,##,###');
    return formatter.format(quantity);
  }

  static String formatChange(num change) {
    if (change > 0) {
      return '+${change.toStringAsFixed(2)}';
    } else if (change < 0) {
      return change.toStringAsFixed(2);
    }
    return '0.00';
  }

  static String formatChangeWithPrecision(num change, {int decimalPlaces = 2}) {
    final decimals = decimalPlaces < 0 ? 0 : decimalPlaces;
    final absoluteValue = change.abs();
    final value = formatPriceWithPrecision(
      absoluteValue,
      decimalPlaces: decimals,
    );
    if (change > 0) {
      return '+$value';
    } else if (change < 0) {
      return '-$value';
    }
    return '0';
  }

  static String formatCompact(num number) {
    final formatter = NumberFormat.compact();
    return formatter.format(number);
  }

  static double? parseFormattedNumber(String formattedNumber) {
    try {
      final cleanNumber = formattedNumber.replaceAll(',', '');
      return double.parse(cleanNumber);
    } catch (e) {
      return null;
    }
  }

  static bool isPositive(num number) => number > 0;
  static bool isNegative(num number) => number < 0;
  static bool isZero(num number) => number == 0;
}
