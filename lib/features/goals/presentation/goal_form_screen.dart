import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/models/goal.dart';
import 'goal_providers.dart';

class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({super.key});

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _monthlyCtrl = TextEditingController();
  bool _loading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    _monthlyCtrl.dispose();
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

    final goal = Goal(
      id: _uuid.v4(),
      userId: userId,
      title: _titleCtrl.text.trim(),
      targetAmount: double.tryParse(_targetCtrl.text.replaceAll(',', '.')) ?? 0,
      monthlyContribution: double.tryParse(_monthlyCtrl.text.replaceAll(',', '.')) ?? 0,
    );

    try {
      await ref.read(goalRepositoryProvider).create(goal);
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
      appBar: AppBar(title: const Text('Nova Meta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Título'), validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null),
            TextFormField(controller: _targetCtrl, decoration: const InputDecoration(labelText: 'Valor Alvo'), keyboardType: TextInputType.number, validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null),
            TextFormField(controller: _monthlyCtrl, decoration: const InputDecoration(labelText: 'Contribuição Mensal'), keyboardType: TextInputType.number),
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
