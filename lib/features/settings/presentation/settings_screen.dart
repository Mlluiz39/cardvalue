import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../services/drift_database.dart';
import '../../../services/export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    final db = AppDatabase();
    final exportService = ExportService(db);

    try {
      final file = await exportService.exportToJsonFile();
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Backup Concluído'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Seus dados foram exportados com sucesso em JSON!'),
              const SizedBox(height: 12),
              Text(
                'Caminho:\n${file.path}',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final text = await file.readAsString();
                await Clipboard.setData(ClipboardData(text: text));
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Conteúdo do backup copiado para a área de transferência!')),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Copiar JSON'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar dados: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () => context.push('/settings/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorias'),
            onTap: () => context.push('/settings/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.label),
            title: const Text('Tags'),
            onTap: () => context.push('/settings/tags'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificações'),
            onTap: () => context.push('/settings/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Aparência'),
            onTap: () => context.push('/settings/appearance'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Exportar Dados Locais'),
            subtitle: const Text('Gerar arquivo de backup em formato JSON'),
            onTap: () => _exportData(context),
          ),
        ],
      ),
    );
  }
}
