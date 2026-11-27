import 'package:flutter/material.dart';

class InicioScreen extends StatelessWidget {
  final String email;

  const InicioScreen({super.key, required this.email});

  Future<void> sair() async{}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ínicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: sair,
          ),
        ],
      ),
      body: Center(
        child: Text('Logado com $email', style: const TextStyle(fontSize: 20),),
      ),
    );
  }
}