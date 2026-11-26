import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'lista_incidentes_screen.dart';

class PapelGate extends StatefulWidget {
  final String uid;

  const PapelGate({super.key, required this.uid});

  @override
  State<PapelGate> createState() => _PapelGateState();
}

class _PapelGateState extends State<PapelGate> {
  late final Future<DocumentSnapshot<Map<String, dynamic>>> leitura;

  @override
  void initState() {
    super.initState();
    leitura = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: leitura,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final perfil = snapshot.data!;
        if (!perfil.exists) {
          return const ContaSemPapelScreen();
        }
        final papel = perfil['papel'];
        return ListaIncidentesScreen(papel: papel);
      },
    );
  }
}

class ContaSemPapelScreen extends StatelessWidget {
  const ContaSemPapelScreen({super.key});

  Future<void> sair() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Central de Incidentes')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Conta sem papel. Peça acesso a um administrador.'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: sair, child: const Text('Sair')),
          ],
        ),
      ),
    );
  }
}
