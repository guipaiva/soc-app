import 'package:flutter/material.dart';

void main() {
  runApp(const CentralIncidentesApp());
}

class CentralIncidentesApp extends StatelessWidget {
  const CentralIncidentesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Central de Incidentes',
      home: Scaffold(
        appBar: AppBar(title: const Text('Central de Incidentes')),
        body: ListView(
          children: incidentesExemplo
              .map((incidente) => IncidenteCard(incidente: incidente))
              .toList(),
        ),
      ),
    );
  }
}

enum TipoIncidente { phishing, malware, acessoNaoAutorizado, ddos, outro }

enum Severidade { critico, alto, medio, baixo }

enum StatusIncidente { aberto, emAndamento, resolvido }

class Incidente {
  final String id;
  final String titulo;
  final TipoIncidente tipo;
  final Severidade severidade;
  final StatusIncidente status;
  final DateTime abertoEm;
  final String? responsavel;

  Incidente({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.severidade,
    required this.status,
    required this.abertoEm,
    this.responsavel,
  });

  String get tempoDecorrido {
    final diferenca = DateTime.now().difference(abertoEm);

    if (diferenca.inMinutes < 60) {
      return 'há ${diferenca.inMinutes}min';
    } else if (diferenca.inHours < 24) {
      return 'há ${diferenca.inHours}h';
    } else {
      return 'há ${diferenca.inDays} dias';
    }
  }
}

String tipoTexto(TipoIncidente tipo) {
  switch (tipo) {
    case TipoIncidente.phishing:
      return 'Phishing';
    case TipoIncidente.malware:
      return 'Malware';
    case TipoIncidente.acessoNaoAutorizado:
      return 'Acesso não autorizado';
    case TipoIncidente.ddos:
      return 'DDoS';
    case TipoIncidente.outro:
      return 'Outro';
  }
}

String severidadeTexto(Severidade severidade) {
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

String statusTexto(StatusIncidente status) {
  switch (status) {
    case StatusIncidente.aberto:
      return 'Aberto';
    case StatusIncidente.emAndamento:
      return 'Em andamento';
    case StatusIncidente.resolvido:
      return 'Resolvido';
  }
}

IconData iconeSeveridade(Severidade severidade) {
  switch (severidade) {
    case Severidade.critico:
      return Icons.dangerous;
    case Severidade.alto:
      return Icons.warning_amber_rounded;
    case Severidade.medio:
      return Icons.error_outline;
    case Severidade.baixo:
      return Icons.info_outline;
  }
}

Color corSeveridade(Severidade severidade) {
  switch (severidade) {
    case Severidade.critico:
      return Colors.red;
    case Severidade.alto:
      return Colors.orange;
    case Severidade.medio:
      return Colors.amber.shade800;
    case Severidade.baixo:
      return Colors.blueGrey;
  }
}

final List<Incidente> incidentesExemplo = [
  Incidente(
    id: 'INC-1042',
    titulo: 'Tentativa de phishing via e-mail corporativo',
    tipo: TipoIncidente.phishing,
    severidade: Severidade.alto,
    status: StatusIncidente.aberto,
    abertoEm: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  Incidente(
    id: 'INC-1043',
    titulo: 'Certificado TLS expirado no servidor de pagamentos',
    tipo: TipoIncidente.outro,
    severidade: Severidade.critico,
    status: StatusIncidente.emAndamento,
    abertoEm: DateTime.now().subtract(const Duration(hours: 3)),
    responsavel: 'Marina Alves',
  ),
  Incidente(
    id: 'INC-1044',
    titulo: 'Login suspeito fora do horário comercial',
    tipo: TipoIncidente.acessoNaoAutorizado,
    severidade: Severidade.medio,
    status: StatusIncidente.resolvido,
    abertoEm: DateTime.now().subtract(const Duration(days: 2)),
    responsavel: 'Diego Ramos',
  ),
  Incidente(
    id: 'INC-1045',
    titulo: 'Varredura de portas detectada no firewall',
    tipo: TipoIncidente.ddos,
    severidade: Severidade.baixo,
    status: StatusIncidente.aberto,
    abertoEm: DateTime.now().subtract(const Duration(minutes: 40)),
  ),
  Incidente(
    id: 'INC-1046',
    titulo: 'Malware identificado em estação de trabalho',
    tipo: TipoIncidente.malware,
    severidade: Severidade.alto,
    status: StatusIncidente.emAndamento,
    abertoEm: DateTime.now().subtract(const Duration(hours: 6)),
    responsavel: 'Marina Alves',
  ),
  Incidente(
    id: 'INC-1047',
    titulo: 'Pico de tráfego suspeito no servidor web',
    tipo: TipoIncidente.ddos,
    severidade: Severidade.critico,
    status: StatusIncidente.resolvido,
    abertoEm: DateTime.now().subtract(const Duration(days: 5)),
    responsavel: 'Diego Ramos',
  ),
  Incidente(
    id: 'INC-1048',
    titulo: 'Múltiplas tentativas de login falhas na VPN',
    tipo: TipoIncidente.acessoNaoAutorizado,
    severidade: Severidade.medio,
    status: StatusIncidente.aberto,
    abertoEm: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
];

class IncidenteCard extends StatelessWidget {
  final Incidente incidente;

  const IncidenteCard({super.key, required this.incidente});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  iconeSeveridade(incidente.severidade),
                  color: corSeveridade(incidente.severidade),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    incidente.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('#${incidente.id} · ${tipoTexto(incidente.tipo)}'),
            const SizedBox(height: 2),
            Text(
              '${severidadeTexto(incidente.severidade)} · ${statusTexto(incidente.status)}',
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(incidente.responsavel ?? 'Sem responsável'),
                Text(incidente.tempoDecorrido),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
