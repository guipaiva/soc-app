import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../services/reputacao.dart';
import '../widgets/incidente_card.dart';

class DetalheIncidenteScreen extends StatefulWidget {
  final Incidente incidente;
  final bool podeMudarStatus;
  final bool podeExcluir;

  const DetalheIncidenteScreen({
    super.key,
    required this.incidente,
    required this.podeMudarStatus,
    required this.podeExcluir,
  });

  @override
  State<DetalheIncidenteScreen> createState() => _DetalheIncidenteScreenState();
}

class _DetalheIncidenteScreenState extends State<DetalheIncidenteScreen> {
  StatusIncidente? escolhido;
  Future<Map<String, dynamic>>? reputacao;

  @override
  void initState() {
    super.initState();
    final ip = widget.incidente.ipRelacionado;
    if (ip != null) {
      reputacao = consultarReputacao(ip);
    }
  }

  void consultarDeNovo() {
    setState(() {
      reputacao = consultarReputacao(widget.incidente.ipRelacionado!);
    });
  }

  Future<void> excluir() async {
    await FirebaseFirestore.instance
        .collection('incidentes')
        .doc(widget.incidente.id)
        .delete();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Color corDoScore(int score) {
    if (score >= 75) {
      return Colors.red.shade700;
    }
    if (score >= 25) {
      return Colors.orange.shade800;
    }
    return Colors.green.shade700;
  }

  Widget secaoReputacao() {
    return FutureBuilder(
      future: reputacao,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Sem conexão com a AbuseIPDB');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final dados = snapshot.data!;
        if (dados['erro'] != null) {
          return Text('Consulta falhou: ${dados['erro']}');
        }
        final int score = dados['abuseConfidenceScore'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score de abuso: $score%',
              style: TextStyle(
                color: corDoScore(score),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('País: ${dados['countryCode'] ?? '—'}'),
            Text('Provedor: ${dados['isp'] ?? '—'}'),
            Text('Denúncias: ${dados['totalReports']}'),
          ],
        );
      },
    );
  }

  Widget campo(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(rotulo, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidente = widget.incidente;
    final status = escolhido ?? incidente.status;
    final corSeveridade = corDaSeveridade(incidente.severidade);

    return Scaffold(
      appBar: AppBar(title: Text('#${incidente.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Chip(
                label: Text(
                  textoDaSeveridade(incidente.severidade),
                  style: TextStyle(
                    color: corSeveridade,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: corSeveridade.withValues(alpha: 0.14),
                side: BorderSide(color: corSeveridade),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            incidente.titulo,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          campo('Tipo', incidente.tipo),
          campo('Aberto', incidente.abertoHa),
          campo('Responsável', incidente.responsavel ?? 'Sem responsável'),
          campo('IP relacionado', incidente.ipRelacionado ?? '—'),
          const SizedBox(height: 16),
          const Text(
            'Descrição',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(incidente.descricao),
          if (incidente.ipRelacionado != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Reputação do IP',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            secaoReputacao(),
            TextButton(
              onPressed: consultarDeNovo,
              child: const Text('Consultar de novo'),
            ),
          ],
          const SizedBox(height: 16),
          if (widget.podeMudarStatus) ...[
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: StatusIncidente.values
                  .map(
                    (opcao) => ChoiceChip(
                      label: Text(opcao.texto),
                      selected: opcao == status,
                      onSelected: (_) {
                        setState(() {
                          escolhido = opcao;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, status);
              },
              child: const Text('Salvar atualização'),
            ),
          ],
          if (widget.podeExcluir) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: excluir,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir incidente'),
            ),
          ],
        ],
      ),
    );
  }
}
