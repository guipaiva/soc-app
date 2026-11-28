import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/incidente.dart';

class DetalheIncidenteScreen extends StatefulWidget {
  final Incidente incidente;
  final String papel;

  const DetalheIncidenteScreen({
    super.key,
    required this.incidente,
    required this.papel,
  });

  @override
  State<DetalheIncidenteScreen> createState() =>
      _DetalheIncidenteScreenState();
}

class _DetalheIncidenteScreenState
    extends State<DetalheIncidenteScreen> {
  bool carregando = false;

  bool get podeAlterarStatus =>
      widget.papel == 'analista' || widget.papel == 'admin';

  bool get podeExcluir => widget.papel == 'admin';

  String textoSeveridade(Severidade severidade) {
    switch (severidade) {
      case Severidade.critico:
        return 'Crítico';
      case Severidade.alto:
        return 'Alto';
      case Severidade.medio:
        return 'Médio';
      case Severidade.baixo:
        return 'Baixo';
    }
  }

  Future<void> alterarStatus() async {
    final proximo = widget.incidente.status.proximo;

    setState(() {
      carregando = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('incidentes')
          .doc(widget.incidente.id)
          .update({
        'status': proximo.name,
      });

      if (!mounted) return;

      setState(() {
        widget.incidente.status = proximo;
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status alterado para ${proximo.texto}.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar status: $e'),
        ),
      );
    }
  }

  Future<void> excluirIncidente() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir incidente'),
          content: const Text(
            'Tem certeza que deseja excluir este incidente? '
            'Esta ação não poderá ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    setState(() {
      carregando = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('incidentes')
          .doc(widget.incidente.id)
          .delete();

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incidente excluído.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir incidente: $e'),
        ),
      );
    }
  }

  Widget campo(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor.isEmpty ? 'Não informado' : valor,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidente = widget.incidente;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhe ${incidente.id}'),
      ),
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  incidente.titulo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                campo('Identificador', incidente.id),
                campo('Tipo', incidente.tipo),
                campo(
                  'Severidade',
                  textoSeveridade(incidente.severidade),
                ),
                campo('Status', incidente.status.texto),
                campo('Responsável', incidente.responsavel ?? ''),
                campo('IP relacionado', incidente.ipRelacionado ?? ''),
                campo(
                  'Data de abertura',
                  incidente.abertoEm.toString(),
                ),
                campo('Descrição', incidente.descricao),

                const SizedBox(height: 24),

                if (podeAlterarStatus)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: alterarStatus,
                      icon: const Icon(Icons.sync),
                      label: Text(
                        'Avançar status (${incidente.status.texto})',
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                if (podeExcluir)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: excluirIncidente,
                      icon: const Icon(Icons.delete),
                      label: const Text('Excluir incidente'),
                    ),
                  ),

                if (!podeAlterarStatus && !podeExcluir)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Você possui permissão somente para visualizar '
                        'este incidente.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}