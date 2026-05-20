import 'package:intl/intl.dart';

extension NumExtension on num {
  String get currency {
    final format = NumberFormat.currency(locale: 'pt-BR', symbol: 'R\$');
    return format.format(this);
  }

  String get percent => '${toStringAsFixed(1)}%';
}
