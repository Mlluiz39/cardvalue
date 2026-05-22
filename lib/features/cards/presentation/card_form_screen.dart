import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/utils/validators.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/models/card.dart' as domain;
import 'card_providers.dart';

class CardFormScreen extends ConsumerStatefulWidget {
  final String? cardId;

  const CardFormScreen({super.key, this.cardId});

  @override
  ConsumerState<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends ConsumerState<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _limitCtrl = TextEditingController();
  final _closingDayCtrl = TextEditingController();
  final _dueDayCtrl = TextEditingController();
  String _brand = 'visa';
  bool _isPhysical = true;
  bool _loading = false;

  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.cardId != null) _loadCard();
  }

  Future<void> _loadCard() async {
    final card = await ref.read(cardRepositoryProvider).getById(widget.cardId!);
    if (card != null && mounted) {
      _bankNameCtrl.text = card.bankName;
      _cardNameCtrl.text = card.cardName;
      _limitCtrl.text = card.limitAmount.toStringAsFixed(2);
      _closingDayCtrl.text = card.closingDay.toString();
      _dueDayCtrl.text = card.dueDay.toString();
      setState(() {
        _brand = card.brand;
        _isPhysical = card.cardType == 'physical';
      });
    }
  }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _cardNameCtrl.dispose();
    _limitCtrl.dispose();
    _closingDayCtrl.dispose();
    _dueDayCtrl.dispose();
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

    final card = domain.CardModel(
      id: widget.cardId ?? _uuid.v4(),
      userId: userId,
      bankName: _bankNameCtrl.text.trim(),
      cardName: _cardNameCtrl.text.trim(),
      brand: _brand,
      cardType: _isPhysical ? 'physical' : 'virtual',
      limitAmount: double.tryParse(_limitCtrl.text.replaceAll(',', '.')) ?? 0,
      closingDay: int.tryParse(_closingDayCtrl.text) ?? 15,
      dueDay: int.tryParse(_dueDayCtrl.text) ?? 22,
    );

    try {
      if (widget.cardId != null) {
        await ref.read(cardRepositoryProvider).update(card);
      } else {
        await ref.read(cardRepositoryProvider).create(card);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Erro ao salvar cartão'), backgroundColor: AppColors.expense));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cardId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Cartão' : 'Novo Cartão')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            TextFormField(
              controller: _bankNameCtrl,
              decoration: const InputDecoration(labelText: 'Banco'),
              validator: Validators.required,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _cardNameCtrl,
              decoration: const InputDecoration(labelText: 'Nome do Cartão'),
              validator: Validators.required,
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              value: _brand,
              decoration: const InputDecoration(labelText: 'Bandeira'),
              items: const [
                DropdownMenuItem(value: 'visa', child: Text('Visa')),
                DropdownMenuItem(value: 'mastercard', child: Text('Mastercard')),
                DropdownMenuItem(value: 'amex', child: Text('American Express')),
                DropdownMenuItem(value: 'elo', child: Text('Elo')),
                DropdownMenuItem(value: 'hipercard', child: Text('Hipercard')),
                DropdownMenuItem(value: 'other', child: Text('Outra')),
              ],
              onChanged: (v) => setState(() => _brand = v ?? 'visa'),
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile(
              title: const Text('Cartão Físico'),
              value: _isPhysical,
              onChanged: (v) => setState(() => _isPhysical = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _limitCtrl,
              decoration: const InputDecoration(labelText: 'Limite (R\$)', prefixText: 'R\$ '),
              keyboardType: TextInputType.number,
              validator: Validators.positiveNumber,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _closingDayCtrl,
              decoration: const InputDecoration(labelText: 'Dia Fechamento (1-31)'),
              keyboardType: TextInputType.number,
              validator: Validators.dayOfMonth,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _dueDayCtrl,
              decoration: const InputDecoration(labelText: 'Dia Vencimento (1-31)'),
              keyboardType: TextInputType.number,
              validator: Validators.dayOfMonth,
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
