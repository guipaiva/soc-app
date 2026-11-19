import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../services/abuseipdb_service.dart';
import '../widgets/incidente_card.dart';

class DetalheIncidenteScreen extends StatefulWidget {
  final Incidente incidente;

  const DetalheIncidenteScreen({super.key, required this.incidente});

  @override
  State<DetalheIncidenteScreen> createState() => _DetalheIncidenteScreenState();
}

class _DetalheIncidenteScreenState extends State<DetalheIncidenteScreen> {
  StatusIncidente? escolhido;

  // Criada uma vez no initState; o setState do status reaproveita o mesmo Future.
  Future<AbuseIpdbResultado>? reputacao;

  String? ip;

  @override
  void initState() {
    super.initState();
    final bruto = widget.incidente.ipRelacionado?.trim();
    if (bruto != null && bruto.isNotEmpty) {
      ip = bruto;
      reputacao = consultarIp(bruto);
    }
  }

  // Só roda quando o usuário toca no botão; troca o Future e o FutureBuilder refaz a consulta.
  void consultarDeNovo() {
    if (ip == null) return;
    setState(() {
      reputacao = consultarIp(ip!);
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
          Text(valor, style: TextStyle(fontWeight: FontWeight.bold, color: cor)),
        ],
      ),
    );
  }

  Color corDoScore(int score) {
    if (score >= 75) return Colors.red;
    if (score >= 25) return Colors.orange;
    return Colors.green;
  }

  Widget secaoReputacao() {
    return FutureBuilder<AbuseIpdbResultado>(
      future: reputacao,
      builder: (context, snapshot) {
        Widget conteudo;
        final carregando = snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active;

        if (snapshot.connectionState == ConnectionState.none) {
          // 1) Sem conexão: o FutureBuilder não tem Future ligado a ele.
          conteudo = Text(
            'Nenhuma consulta iniciada.',
            style: TextStyle(color: Colors.grey.shade700),
          );
        } else if (carregando) {
          // 2) Carregando
          conteudo = const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Consultando AbuseIPDB...'),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          // 3) Erro
          final erro = snapshot.error;
          final mensagem =
              erro is AbuseIpdbException ? erro.mensagem : erro.toString();
          conteudo = Text(
            'Não foi possível consultar: $mensagem',
            style: const TextStyle(color: Colors.red),
          );
        } else {
          // 4) Dados
          final r = snapshot.data!;
          conteudo = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              campo(
                'Score de abuso',
                '${r.abuseConfidenceScore}%',
                cor: corDoScore(r.abuseConfidenceScore),
              ),
              campo('País', r.countryCode ?? '—'),
              campo('Provedor', r.isp ?? '—'),
              campo('Denúncias', '${r.totalReports}'),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Reputação do IP',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            conteudo,
            const SizedBox(height: 8),
            OutlinedButton.icon(
              // Desabilitado enquanto carrega, pra não disparar consultas em paralelo.
              onPressed: carregando ? null : consultarDeNovo,
              icon: const Icon(Icons.refresh),
              label: const Text('Consultar de novo'),
            ),
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
          if (reputacao != null) secaoReputacao(),
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