import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../services/invoice_parser_service.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../cards/presentation/card_providers.dart';
import '../../installments/domain/models/purchase.dart';
import '../../installments/presentation/purchase_providers.dart';

class ReconciliationScreen extends ConsumerStatefulWidget {
  final String cardId;
  final List<InvoiceLineItem> parsedItems;

  const ReconciliationScreen({
    super.key,
    required this.cardId,
    required this.parsedItems,
  });

  @override
  ConsumerState<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends ConsumerState<ReconciliationScreen> {
  bool _importing = false;

  Future<void> _importUnmatchedItem(InvoiceLineItem item) async {
    setState(() => _importing = true);
    final userId = ref.read(userIdProvider);
    final card = await ref.read(cardRepositoryProvider).getById(widget.cardId);

    if (userId.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não autenticado')));
      setState(() => _importing = false);
      return;
    }

    final purchase = Purchase(
      id: const Uuid().v4(),
      cardId: widget.cardId,
      userId: userId,
      merchantName: item.description,
      totalAmount: item.amount,
      categoryId: 'other',
      purchaseDate: DateTime.now(),
      installmentCount: 1,
    );

    try {
      await ref.read(purchaseRepositoryProvider).createWithInstallments(purchase, card?.closingDay ?? 15);

      ref.invalidate(purchaseListProvider);
      ref.invalidate(cardInstallmentsProvider(widget.cardId));
      ref.invalidate(cardDetailProvider(widget.cardId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${item.description}" importado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao importar item: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final installmentsAsync = ref.watch(cardInstallmentsProvider(widget.cardId));
    final purchasesAsync = ref.watch(purchaseListProvider);
    final cardAsync = ref.watch(cardDetailProvider(widget.cardId));

    final totalPdfAmount = widget.parsedItems.fold<double>(0, (sum, i) => sum + i.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Conciliação de Fatura')),
      body: cardAsync.when(
        data: (card) {
          if (card == null) return const Center(child: Text('Cartão não encontrado'));

          return installmentsAsync.when(
            data: (installments) {
              return purchasesAsync.when(
                data: (purchases) {
                  final List<Map<String, dynamic>> comparisonList = [];
                  int matchedCount = 0;
                  int unmatchedCount = 0;
                  double matchedAmount = 0.0;
                  final matchedInstallmentIds = <String>{};

                  for (final pdfItem in widget.parsedItems) {
                    // Find matching installment by amount
                    dynamic matchingInst;
                    for (final inst in installments) {
                      if ((inst.amount - pdfItem.amount).abs() < 0.01 && !matchedInstallmentIds.contains(inst.id)) {
                        matchingInst = inst;
                        break;
                      }
                    }

                    if (matchingInst != null) {
                      matchedInstallmentIds.add(matchingInst.id as String);
                      matchedCount++;
                      matchedAmount += pdfItem.amount;

                      // Find the purchase for this installment
                      dynamic localPurchase;
                      for (final p in purchases) {
                        if (p.id == matchingInst.purchaseId) {
                          localPurchase = p;
                          break;
                        }
                      }

                      comparisonList.add({
                        'pdf_item': pdfItem,
                        'is_matched': true,
                        'local_purchase': localPurchase,
                        'local_installment': matchingInst,
                      });
                    } else {
                      unmatchedCount++;
                      comparisonList.add({
                        'pdf_item': pdfItem,
                        'is_matched': false,
                        'local_purchase': null,
                        'local_installment': null,
                      });
                    }
                  }

                  return Column(
                    children: [
                      // Overview Card
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${card.bankName} - ${card.cardName}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Valor Total do PDF:'),
                                  Text(
                                    'R\$ ${totalPdfAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Valor Conciliado:'),
                                  Text(
                                    'R\$ ${matchedAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(children: [
                                    Text('$matchedCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                                    const Text('Conciliados', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ]),
                                  Column(children: [
                                    Text('$unmatchedCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                                    const Text('Divergentes', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Detalhamento dos Lançamentos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: comparisonList.length,
                          itemBuilder: (context, index) {
                            final compare = comparisonList[index];
                            final pdfItem = compare['pdf_item'] as InvoiceLineItem;
                            final isMatched = compare['is_matched'] as bool;
                            final localPurchase = compare['local_purchase'] as Purchase?;
                            final localInstallment = compare['local_installment'];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  isMatched ? Icons.check_circle : Icons.warning,
                                  color: isMatched ? Colors.green : Colors.orange,
                                  size: 32,
                                ),
                                title: Text(pdfItem.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: isMatched
                                    ? Text(
                                        'Reconciliado com "${localPurchase?.merchantName ?? 'Compra'}"',
                                        style: const TextStyle(fontSize: 12, color: Colors.green),
                                      )
                                    : const Text(
                                        'Esta cobrança não está cadastrada no aplicativo!',
                                        style: TextStyle(fontSize: 12, color: Colors.orange),
                                      ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'R\$ ${pdfItem.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isMatched ? Colors.green : Colors.black87,
                                      ),
                                    ),
                                    if (!isMatched) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                                        onPressed: _importing ? null : () => _importUnmatchedItem(pdfItem),
                                        tooltip: 'Lançar compra no aplicativo',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => context.pop(),
                            child: const Text('Concluir Conciliação'),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro ao carregar compras: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro ao carregar parcelas: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar cartão: $e')),
      ),
    );
  }
}
