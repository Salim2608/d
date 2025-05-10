import 'package:intl/intl.dart';

String formatDateString(String? rawDate) {
  if (rawDate == null) return 'No Date';

  try {
    // First, try parsing with the exact format
    final date = DateTime.parse(rawDate);

    // Format time in 12-hour format with AM/PM
    final timeFormat = DateFormat('hh:mm a');
    final timeString = timeFormat.format(date);

    // Format date as dd/mm/yyyy
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dateString = dateFormat.format(date);

    return '$timeString - $dateString';
  } catch (e) {
    // If parsing fails, try alternative formats
    try {
      // Handle cases where the date might come in different formats
      final formatsToTry = [
        'yyyy/MM/dd HH:mm:ss Z',
        'yyyy-MM-dd HH:mm:ss Z',
        'yyyy/MM/dd HH:mm:ss',
        'yyyy-MM-dd HH:mm:ss',
      ];

      DateTime? date;
      for (final format in formatsToTry) {
        try {
          date = DateFormat(format).parse(rawDate);
          break;
        } catch (_) {}
      }

      if (date == null) return 'Invalid Date';

      final timeFormat = DateFormat('hh:mm a');
      final timeString = timeFormat.format(date);

      final dateFormat = DateFormat('dd/MM/yyyy');
      final dateString = dateFormat.format(date);

      return '$timeString - $dateString';
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
