import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/credit_card_widget.dart';
import '../../../shared/widgets/invoice_timeline.dart';
import '../../installments/presentation/purchase_providers.dart';
import '../../installments/domain/models/purchase.dart';
import 'card_providers.dart';

class CardDetailScreen extends ConsumerStatefulWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  ConsumerState<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends ConsumerState<CardDetailScreen> {
  int _selectedMonthIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cardAsync = ref.watch(cardDetailProvider(widget.cardId));
    final installmentsAsync = ref.watch(cardInstallmentsProvider(widget.cardId));
    final purchasesAsync = ref.watch(purchaseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Cartão'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/cards/${widget.cardId}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.expense),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: cardAsync.when(
        data: (card) {
          if (card == null) return const Center(child: Text('Cartão não encontrado'));

          return installmentsAsync.when(
            data: (installments) {
              final Map<String, List> groups = {};
              for (final i in installments) {
                final key = '${i.dueDate.year}-${i.dueDate.month.toString().padLeft(2, '0')}';
                groups.putIfAbsent(key, () => []).add(i);
              }

              final sortedKeys = groups.keys.toList()..sort();

              if (sortedKeys.isNotEmpty && _selectedMonthIndex >= sortedKeys.length) {
                _selectedMonthIndex = 0;
              }

              final invoiceMonths = sortedKeys.map((key) {
                final parts = key.split('-');
                final yr = int.parse(parts[0]);
                final mo = int.parse(parts[1]);
                final items = groups[key] ?? [];
                final total = items.fold<double>(0, (sum, i) => sum + i.amount);
                final allPaid = items.every((i) => i.status == 'paid');
                final isCurrent = mo == DateTime.now().month && yr == DateTime.now().year;

                return InvoiceMonth(
                  month: mo,
                  year: yr,
                  total: total,
                  isPaid: allPaid,
                  isCurrent: isCurrent,
                );
              }).toList();

              final selectedKey = sortedKeys.isNotEmpty ? sortedKeys[_selectedMonthIndex] : null;
              final selectedInstallments = selectedKey != null ? groups[selectedKey] ?? [] : [];
              final selectedInvoiceTotal = selectedInstallments.fold<double>(0, (sum, i) => sum + i.amount);
              final selectedInvoicePaid = selectedInstallments.isNotEmpty && selectedInstallments.every((i) => i.status == 'paid');

              return ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  Hero(
                    tag: 'card-${card.id}',
                    child: CreditCardWidget(
                      bankName: card.bankName,
                      cardName: card.cardName,
                      lastDigits: card.id.length >= 4 ? card.id.substring(card.id.length - 4) : card.id,
                      usedAmount: card.usedAmount,
                      totalLimit: card.limitAmount,
                      closingDayText: 'Fecha ${card.closingDay}',
                      dueDayText: 'Vence ${card.dueDay}',
                      color: card.color != null ? Color(int.parse(card.color!.replaceFirst('#', '0xFF'))) : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Faturas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  if (sortedKeys.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: AppSpacing.md),
                              const Text('Nenhuma compra parcelada neste cartão', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    InvoiceTimeline(
                      months: invoiceMonths,
                      selectedIndex: _selectedMonthIndex,
                      onMonthSelected: (idx) {
                        setState(() => _selectedMonthIndex = idx);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Card(
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Fatura de ${invoiceMonths[_selectedMonthIndex].month}/${invoiceMonths[_selectedMonthIndex].year}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: selectedInvoicePaid ? AppColors.successLight : AppColors.warningLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    selectedInvoicePaid ? 'Paga' : 'Aberta',
                                    style: TextStyle(
                                      color: selectedInvoicePaid ? AppColors.success : AppColors.warning,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: AppSpacing.xl),
                            purchasesAsync.when(
                              data: (purchases) {
                                return Column(
                                  children: selectedInstallments.map((inst) {
                                    Purchase? purchase;
                                    for (final p in purchases) {
                                      if (p.id == inst.purchaseId) {
                                        purchase = p;
                                        break;
                                      }
                                    }
                                    final merchantName = purchase?.merchantName ?? 'Estabelecimento Desconhecido';
                                    final isPaid = inst.status == 'paid';

                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(merchantName),
                                      subtitle: Text(
                                        'Parcela ${inst.sequenceNumber} de ${inst.totalInstallments}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            CurrencyFormatter.format(inst.amount),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Checkbox(
                                            value: isPaid,
                                            onChanged: (val) async {
                                              final repo = ref.read(installmentRepositoryProvider);
                                              if (isPaid) {
                                                await repo.markAsPending(inst.id);
                                              } else {
                                                await repo.markAsPaid(inst.id, DateTime.now());
                                              }
                                              ref.invalidate(cardDetailProvider(widget.cardId));
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, _) => Text('Erro ao carregar compras', style: TextStyle(color: AppColors.expense)),
                            ),
                            const Divider(height: AppSpacing.xl),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total da Fatura', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  CurrencyFormatter.format(selectedInvoiceTotal),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.info),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.expense),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Erro ao carregar parcelas'),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(cardInstallmentsProvider(widget.cardId)),
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
              const SizedBox(height: AppSpacing.md),
              const Text('Erro ao carregar cartão'),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(cardDetailProvider(widget.cardId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Cartão'),
        content: const Text('Tem certeza que deseja excluir este cartão? Todas as compras associadas serão mantidas.'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(cardRepositoryProvider).delete(widget.cardId);
        if (context.mounted) context.pop();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Erro ao excluir cartão'), backgroundColor: AppColors.expense),
          );
        }
      }
    }
  }
}
