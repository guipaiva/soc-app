import 'package:flutter/material.dart';
import '../models/incidente.dart';

class NovoIncidenteScreen extends StatefulWidget {
  const NovoIncidenteScreen({super.key});

  @override
  State<NovoIncidenteScreen> createState() => _NovoIncidenteScreenState();
}

class _NovoIncidenteScreenState extends State<NovoIncidenteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Novo incidente')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Criar incidente'),
          ),
        ],
      ),
    );
  }
}
