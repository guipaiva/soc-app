import 'package:flutter/material.dart';

import '../models/incidente.dart';
import '../services/abuseipdb.dart';
import '../widgets/incidente_card.dart';

Color corDoScore(int score) {
  if (score >= 75) return Colors.red;
  if (score >= 25) return Colors.orange;
  return Colors.green;
}

class DetalheIncidenteScreen extends StatefulWidget {
  final Incidente incidente;

  const DetalheIncidenteScreen({super.key, required this.incidente});

  @override
  State<DetalheIncidenteScreen> createState() => _DetalheIncidenteScreenState();
}

class _DetalheIncidenteScreenState extends State<DetalheIncidenteScreen> {
  StatusIncidente? escolhido;
  Future<ReputacaoIp>? reputacao;

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

  Widget campo(String rotulo, String valor, {Color? cor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(rotulo, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Text(
            valor,
            style: TextStyle(fontWeight: FontWeight.bold, color: cor),
          ),
        ],
      ),
    );
  }

  Widget secaoReputacao() {
    return FutureBuilder<ReputacaoIp>(
      future: reputacao,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final erro = snapshot.error;
          return Text(erro is String ? erro : 'Sem conexão.');
        }
        final r = snapshot.data!;
        return Column(
          children: [
            campo('Score de abuso', '${r.score}%', cor: corDoScore(r.score)),
            campo('País', r.pais ?? '—'),
            campo('Provedor', r.provedor ?? '—'),
            campo('Denúncias', '${r.denuncias}'),
          ],
        );
      },
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
            const SizedBox(height: 8),
            secaoReputacao(),
            TextButton(
              onPressed: consultarDeNovo,
              child: const Text('Consultar de novo'),
            ),
          ],
          const SizedBox(height: 16),
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
      ),
    );
  }
}
