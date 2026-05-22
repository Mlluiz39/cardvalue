import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../shared/utils/validators.dart';
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
  final _notesCtrl = TextEditingController();
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
      _notesCtrl.text = transaction.notes ?? '';
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
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final userId = ref.read(userIdProvider);
    if (userId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Usuário não autenticado'), backgroundColor: AppColors.expense));
      setState(() => _loading = false);
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    final transaction = Transaction(
      id: widget.transactionId ?? _uuid.v4(),
      userId: userId,
      type: _type,
      paymentMethod: _paymentMethod,
      categoryId: 'outros',
      description: _descCtrl.text.trim(),
      amount: amount,
      transactionDate: _transactionDate,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Erro ao salvar transação'), backgroundColor: AppColors.expense));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_transactionDate),
      );
      if (mounted) {
        setState(() {
          _transactionDate = DateTime(
            date.year, date.month, date.day,
            time?.hour ?? _transactionDate.hour,
            time?.minute ?? _transactionDate.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactionId != null;
    final isCreditCard = _paymentMethod == 'credit_card';

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Transação' : 'Nova Transação')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Despesa'), icon: Icon(Icons.arrow_downward)),
                ButtonSegment(value: 'income', label: Text('Receita'), icon: Icon(Icons.arrow_upward)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
              validator: Validators.required,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: 'R\$ '),
              keyboardType: TextInputType.number,
              validator: Validators.amount,
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
              items: const [
                DropdownMenuItem(value: 'pix', child: Text('PIX')),
                DropdownMenuItem(value: 'credit_card', child: Text('Cartão de Crédito')),
                DropdownMenuItem(value: 'debit', child: Text('Cartão de Débito')),
                DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
                DropdownMenuItem(value: 'transfer', child: Text('Transferência')),
                DropdownMenuItem(value: 'boleto', child: Text('Boleto')),
                DropdownMenuItem(value: 'subscription', child: Text('Assinatura')),
                DropdownMenuItem(value: 'other', child: Text('Outro')),
              ],
              onChanged: (v) => setState(() => _paymentMethod = v ?? 'pix'),
            ),
            if (isCreditCard) ...[
              const SizedBox(height: AppSpacing.md),
              Card(
                color: AppColors.warningLight,
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Para compras no crédito, use a tela de Compras Parceladas para melhor controle das faturas.',
                          style: TextStyle(color: AppColors.warning, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: InkWell(
                onTap: _selectDate,
                borderRadius: AppRadius.borderRadiusMd,
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Data', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          Text(_transactionDate.format('dd/MM/yyyy HH:mm'), style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Observações (opcional)'),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isEditing ? 'Atualizar' : 'Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
