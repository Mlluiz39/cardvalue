import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../transactions/domain/models/tag.dart';
import '../../transactions/presentation/tag_providers.dart';

class TagManagementScreen extends ConsumerWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      body: tagsAsync.when(
        data: (tags) => tags.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.label_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Nenhuma tag', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Crie tags para organizar suas transações', style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              )
            : Padding(
                padding: AppSpacing.screenPadding,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: tags.map((tag) => Chip(
                    label: Text(tag.name),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _deleteTag(context, ref, tag),
                  )).toList(),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.expense),
              const SizedBox(height: AppSpacing.md),
              const Text('Erro ao carregar tags'),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(tagListProvider),
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

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Tag'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome'), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final userId = ref.read(userIdProvider);
              if (userId == null) return;

              final tag = Tag(
                id: const Uuid().v4(),
                userId: userId,
                name: nameCtrl.text.trim(),
              );

              await ref.read(tagRepositoryProvider).create(tag);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTag(BuildContext context, WidgetRef ref, Tag tag) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Tag'),
        content: Text('Tem certeza que deseja excluir "${tag.name}"?'),
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
      await ref.read(tagRepositoryProvider).delete(tag.id);
    }
  }
}
