import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text('Bem-vindo ao CardValue', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Seu gerenciador financeiro pessoal'),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.push('/login'),
              child: const Text('Começar'),
            ),
          ],
        ),
      ),
    );
  }
}
