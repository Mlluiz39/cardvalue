import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../transactions/domain/models/category.dart';
import '../../transactions/presentation/category_providers.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      body: categoriesAsync.when(
        data: (categories) => categories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Nenhuma categoria', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Crie categorias para organizar suas transações', style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              )
            : ListView.builder(
                padding: AppSpacing.screenPadding,
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cat.colorHex != null
                            ? Color(int.parse(cat.colorHex!.replaceFirst('#', '0xFF')))
                            : Colors.grey,
                        child: Icon(
                          cat.icon != null ? _getIconData(cat.icon!) : Icons.category,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(cat.name),
                      subtitle: Text(cat.type == 'income' ? 'Receita' : 'Despesa'),
                      trailing: cat.isSystem
                          ? Chip(label: const Text('Sistema', style: TextStyle(fontSize: 11)))
                          : IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.expense),
                              onPressed: () => _deleteCategory(context, ref, cat),
                            ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.expense),
              const SizedBox(height: AppSpacing.md),
              const Text('Erro ao carregar categorias'),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(categoryListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shopping_cart': return Icons.shopping_cart;
      case 'directions_car': return Icons.directions_car;
      case 'home': return Icons.home;
      case 'health': return Icons.health_and_safety;
      case 'education': return Icons.school;
      case 'entertainment': return Icons.movie;
      case 'clothing': return Icons.checkroom;
      case 'salary': return Icons.attach_money;
      default: return Icons.category;
    }
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    String type = 'expense';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Despesa')),
                ButtonSegment(value: 'income', label: Text('Receita')),
              ],
              selected: {type},
              onSelectionChanged: (s) => type = s.first,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final userId = ref.read(userIdProvider);
              if (userId == null) return;

              final category = Category(
                id: const Uuid().v4(),
                userId: userId,
                name: nameCtrl.text.trim(),
                type: type,
              );

              await ref.read(categoryRepositoryProvider).create(category);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref, Category cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Categoria'),
        content: Text('Tem certeza que deseja excluir "${cat.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(categoryRepositoryProvider).delete(cat.id);
    }
  }
}
