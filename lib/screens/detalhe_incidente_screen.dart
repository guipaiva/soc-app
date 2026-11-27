import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../models/papel.dart';
import '../services/reputacao.dart';
import '../widgets/incidente_card.dart';

/// Resultado devolvido por esta tela quando o administrador exclui o incidente.
/// Ao salvar o status, a tela devolve o próprio [StatusIncidente].
class ExcluirIncidente {
  const ExcluirIncidente();
}

class DetalheIncidenteScreen extends StatefulWidget {
  final Incidente incidente;
  final Papel papel;

  const DetalheIncidenteScreen({
    super.key,
    required this.incidente,
    required this.papel,
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

  Future<void> confirmarExclusao() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir incidente'),
        content: Text(
          'Excluir #${widget.incidente.id}? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmou == true && mounted) {
      Navigator.pop(context, const ExcluirIncidente());
    }
  }

  @override
  Widget build(BuildContext context) {
    final incidente = widget.incidente;
    final papel = widget.papel;
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
          if (papel.podeMudarStatus) ...[
            const Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
          ] else
            campo('Status', incidente.status.texto),
          if (papel.podeExcluir) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: confirmarExclusao,
              child: const Text('Excluir incidente'),
            ),
          ],
        ],
      ),
    );
  }
}
