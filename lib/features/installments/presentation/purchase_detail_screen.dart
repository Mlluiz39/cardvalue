import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/installment_progress.dart';
import 'purchase_providers.dart';

class PurchaseDetailScreen extends ConsumerWidget {
  final String purchaseId;

  const PurchaseDetailScreen({super.key, required this.purchaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseAsync = ref.watch(purchaseDetailProvider(purchaseId));
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Compra')),
      body: purchaseAsync.when(
        data: (purchase) {
          if (purchase == null) return const Center(child: Text('Compra não encontrada'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(purchase.merchantName, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Valor: R\$ ${purchase.totalAmount.toStringAsFixed(2)}'),
              Text('Parcelas: ${purchase.installmentCount}x'),
              Text('Data: ${purchase.purchaseDate.day}/${purchase.purchaseDate.month}/${purchase.purchaseDate.year}'),
              const SizedBox(height: 16),
              Center(
                child: InstallmentProgress(
                  paidCount: 0,
                  totalCount: purchase.installmentCount,
                  paidAmount: 0,
                  totalAmount: purchase.totalAmount,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
