import 'package:flutter/material.dart';
import '../services/auth_servico.dart';
import '../widgets/formulario_auth.dart';
import 'cadastro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool carregando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Central de Incidentes')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.shield_outlined, size: 56, color: Colors.teal),
                const SizedBox(height: 8),
                const Text(
                  'Entrar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                FormularioAuth(
                  textoBotao: 'Entrar',
                  aoEnviar: entrar,
                  aoMudarCarregamento: (valor) {
                    setState(() {
                      carregando = valor;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  // Evita abrir o cadastro com um login em andamento.
                  onPressed: carregando
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const CadastroScreen(),
                            ),
                          );
                        },
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
