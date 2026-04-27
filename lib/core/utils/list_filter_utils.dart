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

    final direct = DateTime.tryParse(rawValue);
    if (direct != null) return direct.toLocal();

    final spaceNormalized = rawValue.replaceAll('/', '-');
    final secondary = DateTime.tryParse(spaceNormalized);
    return secondary?.toLocal();
  }
}
