import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'cadastro_screen.dart';

String mensagemDeErro(String codigo) {
  switch (codigo) {
    case 'invalid-credential':
      return 'E-mail ou senha incorretos.';
    case 'invalid-email':
      return 'E-mail em formato inválido.';
    case 'too-many-requests':
      return 'Muitas tentativas. Tente de novo mais tarde.';
    case 'network-request-failed':
      return 'Sem conexão com a internet.';
    default:
      return codigo;
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String? erro;
  bool carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        erro = mensagemDeErro(e.code);
      });
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (erro != null)
              Text(erro!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            carregando
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: entrar,
                    child: const Text('Entrar'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CadastroScreen(),
                  ),
                );
              },
              child: const Text('Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}
