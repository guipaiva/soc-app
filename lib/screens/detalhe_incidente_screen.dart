import 'package:flutter/material.dart';

import '../models/incidente.dart';
import '../services/abuseipdb.dart';
import '../widgets/incidente_card.dart';

class DetalheIncidenteScreen extends StatefulWidget {
  final Incidente incidente;

  const DetalheIncidenteScreen({super.key, required this.incidente});

  @override
  State<DetalheIncidenteScreen> createState() => _DetalheIncidenteScreenState();
}

class _DetalheIncidenteScreenState extends State<DetalheIncidenteScreen> {
  StatusIncidente? escolhido;
  Future<ReputacaoIp>? consulta;

  @override
  void initState() {
    super.initState();
    final ip = widget.incidente.ipRelacionado;
    if (ip != null) {
      consulta = consultarReputacao(ip);
    }
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

  Color corDoScore(int score) {
    if (score >= 75) {
      return Colors.red;
    }
    if (score >= 25) {
      return Colors.orange;
    }
    return Colors.green;
  }

  Widget secaoReputacao() {
    return FutureBuilder<ReputacaoIp>(
      future: consulta,
      builder: (context, snapshot) {
        // 1. sem conexão: nenhum Future ligado ao FutureBuilder
        if (snapshot.connectionState == ConnectionState.none) {
          return const Text('Consulta não iniciada.');
        }
        // 2. espera
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        // 3. falha, com o motivo
        if (snapshot.hasError) {
          return Text(
            'Falha na consulta: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }
        // 4. dados
        final reputacao = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score de abuso: ${reputacao.score}%',
              style: TextStyle(
                color: corDoScore(reputacao.score),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('País: ${reputacao.pais ?? '—'}'),
            Text('Provedor: ${reputacao.provedor ?? '—'}'),
            Text('Denúncias: ${reputacao.denuncias}'),
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
            const SizedBox(height: 4),
            secaoReputacao(),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    consulta = consultarReputacao(incidente.ipRelacionado!);
                  });
                },
                child: const Text('Consultar de novo'),
              ),
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
