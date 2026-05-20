import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/models/debt.dart';
import 'debt_providers.dart';

class DebtFormScreen extends ConsumerStatefulWidget {
  const DebtFormScreen({super.key});

  @override
  ConsumerState<DebtFormScreen> createState() => _DebtFormScreenState();
}

class _DebtFormScreenState extends ConsumerState<DebtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _interestCtrl = TextEditingController();
  final _installmentsCtrl = TextEditingController();
  String _priority = 'medium';
  bool _loading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _interestCtrl.dispose();
    _installmentsCtrl.dispose();
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

    final totalAmount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    final installments = int.tryParse(_installmentsCtrl.text) ?? 1;

    final debt = Debt(
      id: _uuid.v4(),
      userId: userId,
      title: _titleCtrl.text.trim(),
      totalAmount: totalAmount,
      remainingAmount: totalAmount,
      interestRate: double.tryParse(_interestCtrl.text.replaceAll(',', '.')) ?? 0,
      totalInstallments: installments,
      remainingInstallments: installments,
      dueDate: DateTime.now().add(const Duration(days: 30)),
      priority: _priority,
    );

    try {
      await ref.read(debtRepositoryProvider).create(debt);
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
      appBar: AppBar(title: const Text('Nova Dívida')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Título'), validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null),
            TextFormField(controller: _amountCtrl, decoration: const InputDecoration(labelText: 'Valor Total'), keyboardType: TextInputType.number, validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null),
            TextFormField(controller: _interestCtrl, decoration: const InputDecoration(labelText: 'Taxa de Juros (%)'), keyboardType: TextInputType.number),
            TextFormField(controller: _installmentsCtrl, decoration: const InputDecoration(labelText: 'Parcelas'), keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Prioridade'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Baixa')),
                DropdownMenuItem(value: 'medium', child: Text('Média')),
                DropdownMenuItem(value: 'high', child: Text('Alta')),
              ],
              onChanged: (v) => setState(() => _priority = v ?? 'medium'),
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
