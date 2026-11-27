import 'package:flutter/material.dart';
import '../services/auth_servico.dart';
import '../widgets/formulario_auth.dart';

class CadastroScreen extends StatelessWidget {
  const CadastroScreen({super.key});

  Future<void> criarConta(
    NavigatorState navigator,
    String email,
    String senha,
  ) async {
    await cadastrar(email, senha);
    // A conta já nasce logada: volta para a raiz, onde o AuthGate mostra a
    // lista de incidentes.
    navigator.popUntil((rota) => rota.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1_outlined,
                  size: 56,
                  color: Colors.teal,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cadastro',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                FormularioAuth(
                  textoBotao: 'Criar conta',
                  novaConta: true,
                  aoEnviar: (email, senha) =>
                      criarConta(navigator, email, senha),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Já tem conta? Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
