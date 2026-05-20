import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../cards/presentation/card_providers.dart';
import '../domain/models/purchase.dart';
import 'purchase_providers.dart';

class PurchaseFormScreen extends ConsumerStatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchantCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _installmentsCtrl = TextEditingController(text: '1');
  final _notesCtrl = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  String? _selectedCardId;
  bool _loading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _amountCtrl.dispose();
    _installmentsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um cartão')));
      return;
    }
    setState(() => _loading = true);

    final userId = ref.read(userIdProvider);
    if (userId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não autenticado')));
      setState(() => _loading = false);
      return;
    }

    final purchase = Purchase(
      id: _uuid.v4(),
      cardId: _selectedCardId!,
      userId: userId,
      merchantName: _merchantCtrl.text.trim(),
      totalAmount: double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0,
      categoryId: 'other',
      purchaseDate: _purchaseDate,
      installmentCount: int.tryParse(_installmentsCtrl.text) ?? 1,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    try {
      final card = await ref.read(cardRepositoryProvider).getById(_selectedCardId!);
      await ref.read(purchaseRepositoryProvider).createWithInstallments(purchase, card?.closingDay ?? 15);
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
      appBar: AppBar(title: const Text('Nova Compra')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _merchantCtrl,
              decoration: const InputDecoration(labelText: 'Estabelecimento'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Valor Total (R\$)'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _installmentsCtrl,
              decoration: const InputDecoration(labelText: 'Parcelas'),
              keyboardType: TextInputType.number,
            ),
            ListTile(
              title: const Text('Data da Compra'),
              subtitle: Text('${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _purchaseDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _purchaseDate = picked);
              },
            ),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Observações'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Adicionar Compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
