import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String format([String pattern = 'dd/MM/yyyy']) {
    return DateFormat(pattern, 'pt-BR').format(this);
  }

  String get monthYear {
    final formatted = DateFormat('MMM/yyyy', 'pt-BR').format(this);
    return formatted.isNotEmpty
        ? '${formatted[0].toUpperCase()}${formatted.substring(1)}'
        : formatted;
  }

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  int get daysInMonth => DateTime(year, month + 1, 0).day;
}
