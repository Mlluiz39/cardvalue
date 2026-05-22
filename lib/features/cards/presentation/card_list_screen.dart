import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/credit_card_widget.dart';
import 'card_providers.dart';

class CardListScreen extends ConsumerWidget {
  const CardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cartões')),
      body: cardsAsync.when(
        data: (cards) => cards.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.credit_card_off, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Nenhum cartão cadastrado', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Adicione seu primeiro cartão de crédito', style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: () => context.push('/cards/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Novo Cartão'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(cardListProvider),
                child: ListView.builder(
                  padding: AppSpacing.screenPadding,
                  itemCount: cards.length,
                  itemBuilder: (_, i) {
                    final card = cards[i];
                    return Hero(
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
                        onTap: () => context.push('/cards/${card.id}'),
                      ),
                    );
                  },
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.expense),
              const SizedBox(height: AppSpacing.md),
              const Text('Erro ao carregar cartões'),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(cardListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/cards/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
