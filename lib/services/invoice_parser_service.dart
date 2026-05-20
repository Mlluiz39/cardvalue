class InvoiceLineItem {
  final String description;
  final double amount;
  final DateTime? date;

  InvoiceLineItem({required this.description, required this.amount, this.date});
}

class InvoiceParserService {
  List<InvoiceLineItem> parsePdf(String rawText) {
    final lines = rawText.split('\n');
    final items = <InvoiceLineItem>[];
    final regex = RegExp(r'^([A-Za-zÀ-ÿ\s*&.]+)\s+R\$\s*([\d,.]+)$');

    for (final line in lines) {
      final match = regex.firstMatch(line.trim());
      if (match != null) {
        final description = match.group(1)!.trim();
        final amountStr = match.group(2)!.replaceAll('.', '').replaceAll(',', '.');
        final amount = double.tryParse(amountStr) ?? 0;
        items.add(InvoiceLineItem(description: description, amount: amount));
      }
    }
    return items;
  }
}
