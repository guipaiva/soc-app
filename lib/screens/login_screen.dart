import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'cadastro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool carregando = false;
  String? erro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    if (!_formKey.currentState!.validate()) return;

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
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-email') {
        erro = 'E-mail ou senha incorretos.';
      } else {
        erro = 'Erro ao entrar: ${e.code}';
      }
    } catch (_) {
      erro = 'Não foi possível realizar o login.';
    }

    if (!mounted) return;

    setState(() {
      carregando = false;
    });
  }

  Future<void> abrirCadastro() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CadastroScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOC App - Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.security,
                  size: 72,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Central de Incidentes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe seu e-mail.';
                    }

                    if (!valor.contains('@')) {
                      return 'Informe um e-mail válido.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Informe sua senha.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                if (erro != null) ...[
                  Text(
                    erro!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: carregando ? null : entrar,
                    child: carregando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Entrar'),
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: carregando ? null : abrirCadastro,
                  child: const Text('Criar conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}