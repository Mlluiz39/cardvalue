import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/installment_progress.dart';
import 'purchase_providers.dart';

class PurchaseDetailScreen extends ConsumerWidget {
  final String purchaseId;

  const PurchaseDetailScreen({super.key, required this.purchaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseAsync = ref.watch(purchaseDetailProvider(purchaseId));
    final installmentsAsync = ref.watch(installmentListProvider(purchaseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Compra')),
      body: purchaseAsync.when(
        data: (purchase) {
          if (purchase == null) return const Center(child: Text('Compra não encontrada'));
          return installmentsAsync.when(
            data: (installments) {
              final paidCount = installments.where((i) => i.status == 'paid').length;
              final totalCount = installments.length;
              final paidAmount = installments.where((i) => i.status == 'paid').fold<double>(0.0, (s, i) => s + i.amount);
              final totalAmount = installments.fold<double>(0.0, (s, i) => s + i.amount);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(purchase.merchantName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Valor: ${CurrencyFormatter.format(purchase.totalAmount)}', style: const TextStyle(fontSize: 16)),
                  Text('Parcelas: ${purchase.installmentCount}x', style: const TextStyle(fontSize: 16)),
                  Text('Data: ${purchase.purchaseDate.format()}', style: const TextStyle(fontSize: 16)),
                  if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Observações: ${purchase.notes}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: InstallmentProgress(
                      paidCount: paidCount,
                      totalCount: totalCount,
                      paidAmount: paidAmount,
                      totalAmount: totalAmount,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Detalhamento das Parcelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: installments.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final inst = installments[index];
                        final isPaid = inst.status == 'paid';
                        return ListTile(
                          title: Text('Parcela ${inst.sequenceNumber} de ${inst.totalInstallments}'),
                          subtitle: Text('Vencimento: ${inst.dueDate.format()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                CurrencyFormatter.format(inst.amount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Checkbox(
                                value: isPaid,
                                onChanged: (val) async {
                                  final repo = ref.read(installmentRepositoryProvider);
                                  if (isPaid) {
                                    await repo.markAsPending(inst.id);
                                  } else {
                                    await repo.markAsPaid(inst.id, DateTime.now());
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.expense),
                  const SizedBox(height: 16),
                  const Text('Erro ao carregar parcelas'),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(installmentListProvider(purchaseId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.expense),
              const SizedBox(height: 16),
              const Text('Erro ao carregar compra'),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(purchaseDetailProvider(purchaseId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
