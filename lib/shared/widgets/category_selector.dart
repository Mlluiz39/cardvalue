import 'package:flutter/material.dart';
import '../../features/transactions/domain/models/category.dart';

class CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final Category? selected;
  final ValueChanged<Category> onSelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Category>(
      initialValue: selected,
      decoration: const InputDecoration(labelText: 'Categoria'),
      items: categories.map((cat) => DropdownMenuItem(
        value: cat,
        child: Text(cat.name),
      )).toList(),
      onChanged: (value) {
        if (value != null) onSelected(value);
      },
    );
  }
}
