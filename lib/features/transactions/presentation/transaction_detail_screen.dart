import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../shared/utils/currency_formatter.dart';
import 'transaction_providers.dart';
import '../domain/models/transaction.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Transação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/transactions/$transactionId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: transactionAsync.when(
        data: (transaction) {
          if (transaction == null) {
            return const Center(child: Text('Transação não encontrada'));
          }
          if (transaction.isIncome) {
            return _buildIncomePremiumView(context, transaction);
          } else {
            return _buildExpenseReceiptView(context, transaction);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.expense),
              const SizedBox(height: 16),
              const Text('Erro ao carregar transação'),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(transactionDetailProvider(transactionId)),
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
        title: const Text('Excluir Transação'),
        content: const Text('Tem certeza que deseja excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(transactionRepositoryProvider).delete(transactionId);
        if (context.mounted) {
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
        }
      }
    }
  }

  String _paymentMethodLabel(String? method) {
    switch (method) {
      case 'pix': return 'PIX';
      case 'debit': return 'Débito';
      case 'cash': return 'Dinheiro';
      case 'transfer': return 'Transferência';
      case 'boleto': return 'Boleto';
      case 'subscription': return 'Assinatura';
      case 'credit_card': return 'Cartão de Crédito';
      default: return 'Outro';
    }
  }

  String _categoryLabel(String categoryId) {
    switch (categoryId) {
      case 'food': return 'Alimentação';
      case 'transport': return 'Transporte';
      case 'housing': return 'Moradia';
      case 'health': return 'Saúde';
      case 'education': return 'Educação';
      case 'entertainment': return 'Lazer';
      case 'clothing': return 'Vestuário';
      case 'salary': return 'Salário';
      case 'freelance': return 'Freelance';
      default: return 'Outros';
    }
  }

  Widget _buildIncomePremiumView(BuildContext context, Transaction t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                const Text('RECEBIMENTO', style: TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(t.amount),
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(t.description, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _premiumDetailRow('Data', t.transactionDate.format('dd/MM/yyyy HH:mm')),
          const Divider(height: 32),
          _premiumDetailRow('Categoria', _categoryLabel(t.categoryId)),
          const Divider(height: 32),
          _premiumDetailRow('Método', _paymentMethodLabel(t.paymentMethod)),
          const Divider(height: 32),
          _premiumDetailRow('ID', t.id.substring(0, 8).toUpperCase()),
        ],
      ),
    );
  }

  Widget _premiumDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }

  Widget _buildExpenseReceiptView(BuildContext context, Transaction t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.yellow.shade50,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Zig-zag top border simulation
              Row(
                children: List.generate(
                  20,
                  (index) => Expanded(
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'COMPROVANTE DE COMPRA',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.description.toUpperCase(),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 20, fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text('- - - - - - - - - - - - - - - - - - - - - -', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    _receiptRow('DATA', t.transactionDate.format('dd/MM/yy HH:mm')),
                    _receiptRow('MÉTODO', _paymentMethodLabel(t.paymentMethod).toUpperCase()),
                    _receiptRow('CATEGORIA', _categoryLabel(t.categoryId).toUpperCase()),
                    const SizedBox(height: 16),
                    const Text('- - - - - - - - - - - - - - - - - - - - - -', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('VALOR TOTAL', style: TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(CurrencyFormatter.format(t.amount), style: const TextStyle(fontFamily: 'monospace', fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('AUT: ${t.id.substring(0, 6).toUpperCase()}', style: const TextStyle(fontFamily: 'monospace', color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    const Text('*** VIA DO CLIENTE ***', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Zig-zag bottom border simulation
              Row(
                children: List.generate(
                  20,
                  (index) => Expanded(
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
          Text(value, style: const TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
