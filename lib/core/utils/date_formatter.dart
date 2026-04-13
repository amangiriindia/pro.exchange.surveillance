import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();
  static String formatToShortDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  static String formatToFullDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatToDateTime(DateTime date) {
    return DateFormat('dd/MM/yy HH:mm:ss').format(date);
  }

  static String formatToDateTimeWithAmPm(DateTime date) {
    return DateFormat('dd/MM/yy hh:mm:ss a').format(date);
  }

  static String formatToTime(DateTime date) {
    return DateFormat('HH:mm:ss').format(date);
  }

  static DateTime? parseShortDate(String dateString) {
    try {
      return DateFormat('dd/MM/yy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseFullDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
