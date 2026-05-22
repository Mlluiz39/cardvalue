import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/invoice_parser_service.dart';

class InvoiceListScreen extends StatefulWidget {
  final String cardId;

  const InvoiceListScreen({super.key, required this.cardId});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  bool _parsing = false;

  Future<void> _pickAndParseInvoice() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Importação de PDF não disponível na web'), backgroundColor: AppColors.warning),
        );
      }
      return;
    }

    setState(() => _parsing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (!mounted) return;

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;

        final parser = InvoiceParserService();
        final text = await parser.extractTextFromPdfBytes(bytes);
        final items = parser.parsePdf(text);

        if (!mounted) return;

        if (items.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Nenhum item de cobrança identificado no PDF.'), backgroundColor: AppColors.warning),
          );
        } else {
          context.push('/invoices/${widget.cardId}/reconciliation', extra: items);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Erro ao importar PDF'), backgroundColor: AppColors.expense),
      );
    } finally {
      if (mounted) setState(() => _parsing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conciliar Faturas')),
      body: _parsing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Extraindo PDF localmente...', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('100% offline no seu aparelho', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
            )
          : ListView(
              padding: AppSpacing.screenPadding,
              children: [
                Card(
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      children: [
                        Icon(Icons.picture_as_pdf, size: 64, color: AppColors.expense),
                        const SizedBox(height: AppSpacing.md),
                        Text('Conciliação de Faturas PDF', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Importe o PDF da fatura e o app compara automaticamente com as compras lançadas, identificando cobranças não cadastradas!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _pickAndParseInvoice,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Selecionar Fatura PDF'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg)),
                  ),
                ),
              ],
            ),
    );
  }
}
