import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/models/transaction.dart';
import 'transaction_providers.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final String? transactionId;

  const TransactionFormScreen({super.key, this.transactionId});

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _type = 'expense';
  String _paymentMethod = 'pix';
  bool _loading = false;
  final _uuid = const Uuid();
  DateTime _transactionDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    final transaction = await ref.read(transactionRepositoryProvider).getById(widget.transactionId!);
    if (transaction != null && mounted) {
      _descCtrl.text = transaction.description;
      _amountCtrl.text = transaction.amount.toStringAsFixed(2);
      setState(() {
        _type = transaction.type;
        _paymentMethod = transaction.paymentMethod ?? 'pix';
        _transactionDate = transaction.transactionDate;
      });
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final userId = ref.read(userIdProvider);
    if (userId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não autenticado')));
      setState(() => _loading = false);
      return;
    }

    final transaction = Transaction(
      id: widget.transactionId ?? _uuid.v4(),
      userId: userId,
      type: _type,
      paymentMethod: _paymentMethod,
      categoryId: 'other',
      description: _descCtrl.text.trim(),
      amount: double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0,
      transactionDate: _transactionDate,
    );

    try {
      if (widget.transactionId != null) {
        await ref.read(transactionRepositoryProvider).update(transaction);
      } else {
        await ref.read(transactionRepositoryProvider).create(transaction);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Transação')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Despesa')),
                ButtonSegment(value: 'income', label: Text('Receita')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 16),
            TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Descrição'), validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null),
            TextFormField(controller: _amountCtrl, decoration: const InputDecoration(labelText: 'Valor'), keyboardType: TextInputType.number, validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Método de Pagamento'),
              items: const [
                DropdownMenuItem(value: 'pix', child: Text('PIX')),
                DropdownMenuItem(value: 'credit_card', child: Text('Cartão de Crédito')),
                DropdownMenuItem(value: 'debit', child: Text('Débito')),
                DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
                DropdownMenuItem(value: 'transfer', child: Text('Transferência')),
                DropdownMenuItem(value: 'boleto', child: Text('Boleto')),
                DropdownMenuItem(value: 'subscription', child: Text('Assinatura')),
                DropdownMenuItem(value: 'other', child: Text('Outro')),
              ],
              onChanged: (v) => setState(() => _paymentMethod = v ?? 'pix'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
