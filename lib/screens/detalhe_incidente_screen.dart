import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../widgets/incidente_card.dart';
import '../services/abuse_ip_service.dart';

class DetalheIncidenteScreen extends StatefulWidget {
  final Incidente incidente;

  const DetalheIncidenteScreen({super.key, required this.incidente});

  @override
  State<DetalheIncidenteScreen> createState() => _DetalheIncidenteScreenState();
}

class _DetalheIncidenteScreenState extends State<DetalheIncidenteScreen> {
  StatusIncidente? escolhido;
  Future<ReputacaoIp>? _futureReputacao;

  @override
  void initState() {
    super.initState();
    final ip = widget.incidente.ipRelacionado;
    if ( ip != null && ip.trim().isNotEmpty) {
      _futureReputacao = consultarReputacaoIp(ip.trim());
    }
  }

  void _reconsultar() {
    final ip = widget.incidente.ipRelacionado;
    if ( ip != null && ip.trim().isNotEmpty) {
      setState(() {
        _futureReputacao = consultarReputacaoIp(ip.trim());
      });
    }
  }

  Color _corDoStore(int score) {
    if (score >= 75) return Colors.red;
    if (score >= 25) return Colors.orange;
    return Colors.green;
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
    final temIp = incidente.ipRelacionado != null && incidente.ipRelacionado!.trim().isNotEmpty;

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

          if (temIp) ...[
            const SizedBox(height: 16),
            const Text (
              'Reputação do IP',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<ReputacaoIp>(
              future: _futureReputacao,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  final erroStr = snapshot.error.toString();
                  final semConexao = erroStr.contains('ClientException') ||
                    erroStr.contains('SocketException') ||
                    erroStr.contains('Failed to fetch');
                  final mensagem = semConexao ?
                    'Sem Conexão com a AbuseIPDB' :
                    erroStr.replaceFirst('Exception: ', '');
                  
                  return Column(
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    children: [
                      Text(
                        mensagem,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _reconsultar, 
                        child: const Text('Consultar de novo'),
                      ),
                    ],
                  );
                }
                final dados = snapshot.data!;
                final corScore = _corDoStore(dados.abuseConfidenceScore);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              'Score de abuso',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          Text(
                            '${dados.abuseConfidenceScore}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: corScore,
                            ),
                          ),
                        ],
                      ),
                    ),
                    campo('País', dados.countryCode ?? '—'),
                    campo('Provedor', dados.isp ?? '—'),
                    campo('Denúncias', '${dados.totalReports}'),
                    const SizedBox(height: 4),
                    OutlinedButton(
                      onPressed: _reconsultar, 
                      child: const Text('Consultar de novo'),
                    ),
                  ],
                );
              },
            )
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
