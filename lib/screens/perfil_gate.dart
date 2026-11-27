import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/papel.dart';
import '../services/auth_servico.dart';
import 'lista_incidentes_screen.dart';

/// Lê o papel em usuarios/'uid' uma única vez, quando o usuário entra, e mostra
/// a lista de incidentes. Sem documento (ou sem papel válido), mostra só o aviso.
class PerfilGate extends StatefulWidget {
  final String uid;

  const PerfilGate({super.key, required this.uid});

  @override
  State<PerfilGate> createState() => _PerfilGateState();
}

class _PerfilGateState extends State<PerfilGate> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> futuroPerfil;

  @override
  void initState() {
    super.initState();
    futuroPerfil = carregarPerfil();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> carregarPerfil() {
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futuroPerfil,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _TelaDeAviso(
            mensagem:
                'Não foi possível carregar o seu perfil. Verifique a conexão '
                'e tente de novo.',
            aoTentarDeNovo: () {
              setState(() {
                futuroPerfil = carregarPerfil();
              });
            },
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final perfil = snapshot.data!;
        if (!perfil.exists) {
          return const _TelaDeAviso(mensagem: _mensagemSemPapel);
        }
        final papel = papelDoTexto(perfil.data()?['papel']);
        if (papel == null) {
          return const _TelaDeAviso(mensagem: _mensagemSemPapel);
        }
        return ListaIncidentesScreen(papel: papel);
      },
    );
  }
}

const _mensagemSemPapel =
    'Conta sem papel. Peça acesso a um administrador.';

class _TelaDeAviso extends StatelessWidget {
  final String mensagem;
  final VoidCallback? aoTentarDeNovo;

  const _TelaDeAviso({required this.mensagem, this.aoTentarDeNovo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Central de Incidentes')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  mensagem,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                if (aoTentarDeNovo != null) ...[
                  ElevatedButton(
                    onPressed: aoTentarDeNovo,
                    child: const Text('Tentar novamente'),
                  ),
                  const SizedBox(height: 8),
                ],
                ElevatedButton(onPressed: sair, child: const Text('Sair')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
