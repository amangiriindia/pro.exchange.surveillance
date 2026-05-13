import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListFilterUtils {
  ListFilterUtils._();

  static bool matchesQuickDate(String? rawValue, String? selectedDate) {
    if (selectedDate == null || selectedDate.isEmpty) return true;

    final normalized = selectedDate.trim().toLowerCase();
    if (normalized == 'all') return true;

    final parsed = _tryParseDate(rawValue);
    if (parsed == null) return false;

    final now = DateTime.now();
    final target = normalized == 'yesterday'
        ? now.subtract(const Duration(days: 1))
        : now;

    return parsed.year == target.year &&
        parsed.month == target.month &&
        parsed.day == target.day;
  }

  static bool matchesDateRangeOrQuick(
    String? rawValue,
    String? selectedDate,
    DateTimeRange? customDateRange,
  ) {
    if (selectedDate == null || selectedDate.isEmpty) return true;
    if (selectedDate.trim().toLowerCase() == 'custom date') {
      if (customDateRange == null) return true;
      final parsed = _tryParseDate(rawValue);
      if (parsed == null) return false;
      final d = DateTime(parsed.year, parsed.month, parsed.day);
      final start = DateTime(
        customDateRange.start.year,
        customDateRange.start.month,
        customDateRange.start.day,
      );
      final end = DateTime(
        customDateRange.end.year,
        customDateRange.end.month,
        customDateRange.end.day,
      );
      return !d.isBefore(start) && !d.isAfter(end);
    }
    return matchesQuickDate(rawValue, selectedDate);
  }

  static bool matchesExact(String? rawValue, String? selectedValue) {
    if (selectedValue == null || selectedValue.isEmpty) return true;

    final normalized = selectedValue.trim().toLowerCase();
    if (normalized == 'all') return true;

    return (rawValue ?? '').trim().toLowerCase() == normalized;
  }

  static bool matchesContains(String? rawValue, String? selectedValue) {
    if (selectedValue == null || selectedValue.isEmpty) return true;

    final normalized = selectedValue.trim().toLowerCase();
    if (normalized == 'all') return true;

    return (rawValue ?? '').toLowerCase().contains(normalized);
  }

  static bool matchesAnyContains(
    String? rawValue,
    List<String> selectedValues,
  ) {
    if (selectedValues.isEmpty) return true;

    final haystack = (rawValue ?? '').toLowerCase();
    return selectedValues.any(
      (value) => haystack.contains(value.toLowerCase()),
    );
  }

  static DateTime? _tryParseDate(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) return null;

    final value = rawValue.trim();

    final direct = DateTime.tryParse(value);
    if (direct != null) return direct.toLocal();

    final spaceNormalized = value.replaceAll('/', '-');
    final secondary = DateTime.tryParse(spaceNormalized);
    if (secondary != null) return secondary.toLocal();

    // App APIs often return date-time values like `02/05/26 12:26:03 AM`.
    // Try common non-ISO formats before giving up.
    const patterns = <String>[
      'dd/MM/yy hh:mm:ss a',
      'dd/MM/yyyy hh:mm:ss a',
      'dd-MM-yy hh:mm:ss a',
      'dd-MM-yyyy hh:mm:ss a',
      'dd/MM/yy HH:mm:ss',
      'dd/MM/yyyy HH:mm:ss',
      'dd-MM-yy HH:mm:ss',
      'dd-MM-yyyy HH:mm:ss',
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd hh:mm:ss a',
      'yyyy/MM/dd HH:mm:ss',
      'yyyy/MM/dd hh:mm:ss a',
      'dd/MM/yy HH:mm',
      'dd/MM/yyyy HH:mm',
      'dd/MM/yy hh:mm a',
      'dd/MM/yyyy hh:mm a',
    ];

    for (final pattern in patterns) {
      try {
        final parsed = DateFormat(pattern).parseStrict(value);
        return parsed.toLocal();
      } catch (_) {
        // Continue trying other formats.
      }
    }

    return null;
  }
}
