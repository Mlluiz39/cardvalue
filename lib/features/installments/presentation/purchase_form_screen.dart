import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../shared/utils/validators.dart';
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
  final _installmentsCtrl = TextEditingController(text: '2');
  final _notesCtrl = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  String? _selectedCardId;
  bool _loading = false;
  bool _isInstallment = false;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Selecione um cartão'), backgroundColor: AppColors.warning));
      return;
    }
    setState(() => _loading = true);

    final userId = ref.read(userIdProvider);
    if (userId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Usuário não autenticado'), backgroundColor: AppColors.expense));
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
      installmentCount: _isInstallment ? (int.tryParse(_installmentsCtrl.text) ?? 2) : 1,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    try {
      final card = await ref.read(cardRepositoryProvider).getById(_selectedCardId!);
      await ref.read(purchaseRepositoryProvider).createWithInstallments(purchase, card?.closingDay ?? 15);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Erro ao salvar compra'), backgroundColor: AppColors.expense));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Compra')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            ref.watch(cardListProvider).when(
              data: (cards) {
                if (cards.isEmpty) {
                  return Card(
                    color: AppColors.warningLight,
                    child: ListTile(
                      leading: Icon(Icons.warning_amber, color: AppColors.warning),
                      title: const Text('Nenhum cartão cadastrado'),
                      subtitle: const Text('Toque aqui para cadastrar um cartão primeiro'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/cards/new'),
                    ),
                  );
                }
                return DropdownButtonFormField<String>(
                  value: _selectedCardId,
                  decoration: const InputDecoration(labelText: 'Cartão de Crédito'),
                  items: cards.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.bankName} - ${c.cardName}'),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedCardId = v),
                  validator: (v) => v == null ? 'Selecione um cartão' : null,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro ao carregar cartões', style: TextStyle(color: AppColors.expense)),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _merchantCtrl,
              decoration: const InputDecoration(labelText: 'Estabelecimento'),
              validator: Validators.required,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Valor Total (R\$)', prefixText: 'R\$ '),
              keyboardType: TextInputType.number,
              validator: Validators.amount,
            ),
            const SizedBox(height: AppSpacing.lg),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('À Vista'), icon: Icon(Icons.shopping_bag_outlined)),
                ButtonSegment(value: true, label: Text('Parcelado'), icon: Icon(Icons.date_range_outlined)),
              ],
              selected: {_isInstallment},
              onSelectionChanged: (v) => setState(() => _isInstallment = v.first),
            ),
            if (_isInstallment) ...[
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _installmentsCtrl,
                decoration: const InputDecoration(labelText: 'Quantidade de Parcelas', hintText: 'Ex: 3', prefixIcon: Icon(Icons.repeat)),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (!_isInstallment) return null;
                  if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                  final num = int.tryParse(v);
                  if (num == null || num < 2) return 'Deve ser no mínimo 2 parcelas';
                  return null;
                },
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
                          Text('Data da Compra', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          Text(_purchaseDate.format(), style: const TextStyle(fontSize: 16)),
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
                    : const Text('Adicionar Compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
