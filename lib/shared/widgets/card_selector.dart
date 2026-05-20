import 'package:flutter/material.dart';

class CardSelector extends StatelessWidget {
  final List<dynamic> cards;
  final dynamic selected;
  final ValueChanged<dynamic> onSelected;

  const CardSelector({
    super.key,
    required this.cards,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<dynamic>(
      initialValue: selected,
      decoration: const InputDecoration(labelText: 'Cartão'),
      items: cards.map((card) => DropdownMenuItem(
        value: card,
        child: Text(card.cardName ?? card.toString()),
      )).toList(),
      onChanged: (value) {
        if (value != null) onSelected(value);
      },
    );
  }
}
