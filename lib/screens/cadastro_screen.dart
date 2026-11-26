import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

String mensagemDeErroCadastro(String codigo) {
  switch (codigo) {
    case 'invalid-email':
      return 'E-mail em formato inválido.';
    case 'missing-password':
      return 'Informe a senha.';
    case 'email-already-in-use':
      return 'Já existe uma conta com este e-mail.';
    case 'weak-password':
      return 'Senha fraca. Use pelo menos 6 caracteres.';
    case 'network-request-failed':
      return 'Sem conexão com a internet.';
    default:
      return codigo;
  }
}

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
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

  Future<void> cadastrar() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        erro = mensagemDeErroCadastro(e.code);
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
      appBar: AppBar(title: const Text('Criar conta')),
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
              decoration: const InputDecoration(
                labelText: 'Senha',
                helperText: 'Pelo menos 6 caracteres',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (erro != null)
              Text(erro!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            carregando
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: cadastrar,
                    child: const Text('Criar conta'),
                  ),
          ],
        ),
      ),
    );
  }
}