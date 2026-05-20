import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _format = NumberFormat.currency(locale: 'pt-BR', symbol: 'R\$');

  static String format(double value) => _format.format(value);

  static double parse(String value) {
    final cleaned = value
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0;
  }
}
