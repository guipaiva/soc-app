import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/incidente.dart';
import '../widgets/incidente_card.dart';

const chaveAbuseIpdb = String.fromEnvironment('ABUSEIPDB_KEY');

Future<Map<String, dynamic>> consultarReputacaoIp(String ip) async {
  final url = Uri.parse('https://api.abuseipdb.com/api/v2/check?ipAddress=$ip');
  final resposta = await http.get(
    url,
    headers: {'Key': chaveAbuseIpdb, 'Accept': 'application/json'},
  );

  final corpo = jsonDecode(resposta.body);
  if (resposta.statusCode != 200) {
    return {'erro': corpo['errors'][0]['detail']};
  }
  return corpo['data'];
}

class DetalheIncidenteScreen extends StatefulWidget {
  final Incidente incidente;

  const DetalheIncidenteScreen({super.key, required this.incidente});

  @override
  State<DetalheIncidenteScreen> createState() => _DetalheIncidenteScreenState();
}

class _DetalheIncidenteScreenState extends State<DetalheIncidenteScreen> {
  StatusIncidente? escolhido;

  Future<Map<String, dynamic>>? consulta;

  @override
  void initState() {
    super.initState();
    final ip = widget.incidente.ipRelacionado;
    if (ip != null && ip.isNotEmpty) {
      consulta = consultarReputacaoIp(ip);
    }
  }

  void consultarDeNovo() {
    setState(() {
      consulta = consultarReputacaoIp(widget.incidente.ipRelacionado!);
    });
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
    return FutureBuilder<Map<String, dynamic>>(
      key: ObjectKey(consulta),
      future: consulta,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Sem conexão com o serviço');
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final dados = snapshot.data!;
        if (dados['erro'] != null) {
          return Text(
            'Consulta falhou: ${dados['erro']}',
            style: TextStyle(color: Colors.red.shade700),
          );
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
            Text('Denúncias: ${dados['totalReports'] ?? '—'}'),
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
          const SizedBox(height: 16),
          if (consulta != null) ...[
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
            const SizedBox(height: 16),
          ],
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
