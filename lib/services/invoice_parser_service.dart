import 'package:syncfusion_flutter_pdf/pdf.dart';

class InvoiceLineItem {
  final String description;
  final double amount;
  final DateTime? date;

  InvoiceLineItem({required this.description, required this.amount, this.date});
}

class InvoiceParserService {
  Future<String> extractTextFromPdfBytes(List<int> bytes) async {
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final PdfTextExtractor extractor = PdfTextExtractor(document);
    final String text = extractor.extractText();
    document.dispose();
    return text;
  }

  List<InvoiceLineItem> parsePdf(String rawText) {
    final lines = rawText.split('\n');
    final items = <InvoiceLineItem>[];
    
    // Matches description followed by optional R$ and amount like 123,45 or 1.234,56
    final regex = RegExp(r'^(.*?)\s+(?:R\$?\s*)?(\d{1,3}(?:\.\d{3})*,\d{2})\s*$');

    for (final line in lines) {
      final cleanLine = line.trim();
      if (cleanLine.isEmpty) continue;
      
      final match = regex.firstMatch(cleanLine);
      if (match != null) {
        var description = match.group(1)!.trim();
        final amountStr = match.group(2)!.replaceAll('.', '').replaceAll(',', '.');
        final amount = double.tryParse(amountStr) ?? 0.0;

        if (amount > 0) {
          // Remove leading transaction dates e.g. "12/04 COMPRA" -> "COMPRA"
          final dateRegex = RegExp(r'^\d{2}/\d{2}\s+');
          description = description.replaceFirst(dateRegex, '');

          final lowerDesc = description.toLowerCase();
          // Skip header, summary, payments, or balance info
          if (lowerDesc.contains('total') || 
              lowerDesc.contains('pagamento') || 
              lowerDesc.contains('saldo') || 
              lowerDesc.contains('fatura') ||
              lowerDesc.contains('crédito rotativo') ||
              lowerDesc.contains('limite')) {
            continue;
          }

          items.add(InvoiceLineItem(description: description, amount: amount));
        }
      }
    }
    return items;
  }
}
