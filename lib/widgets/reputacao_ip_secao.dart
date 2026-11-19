import 'package:flutter/material.dart';

import '../services/reputacao_ip_servico.dart';

/// Seção "Reputação do IP". Use só quando o incidente tiver IP relacionado.
class ReputacaoIpSecao extends StatefulWidget {
  final String ip;
  const ReputacaoIpSecao({super.key, required this.ip});

  @override
  State<ReputacaoIpSecao> createState() => _ReputacaoIpSecaoState();
}

class _ReputacaoIpSecaoState extends State<ReputacaoIpSecao> {
  // O Future vive no State: uma consulta quando o detalhe abre.
  // Rebuilds da tela (ex.: escolher outro status) não criam consulta nova.
  late Future<ReputacaoIp> _consulta;

  @override
  void initState() {
    super.initState();
    _consulta = consultarReputacaoIp(widget.ip);
  }

  void _consultarDeNovo() {
    setState(() {
      _consulta = consultarReputacaoIp(widget.ip);
    });
  }

  Color _corDoScore(int score) {
    if (score >= 75) return Colors.red;
    if (score >= 25) return Colors.orange;
    return Colors.green;
  }

  String _ou(String? valor) => (valor == null || valor.isEmpty) ? '—' : valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reputação do IP',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        FutureBuilder<ReputacaoIp>(
          future: _consulta,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final erro = snapshot.error;
              final semConexao = erro is SemConexaoException;
              final mensagem = semConexao
                  ? 'Sem conexão. Verifique a internet e tente de novo.'
                  : 'Falha na consulta: ${erro is FalhaConsultaException ? erro.motivo : erro}';
              return _comBotao(
                Row(
                  children: [
                    Icon(semConexao ? Icons.wifi_off : Icons.error_outline),
                    const SizedBox(width: 8),
                    Expanded(child: Text(mensagem)),
                  ],
                ),
              );
            }
            final r = snapshot.data!;
            return _comBotao(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score de abuso: ${r.score}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _corDoScore(r.score),
                    ),
                  ),
                  Text('País: ${_ou(r.pais)}'),
                  Text('Provedor: ${_ou(r.provedor)}'),
                  Text('Denúncias: ${r.denuncias?.toString() ?? '—'}'),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _comBotao(Widget conteudo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        conteudo,
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _consultarDeNovo,
            child: const Text('Consultar de novo'),
          ),
        ),
      ],
    );
  }
}
