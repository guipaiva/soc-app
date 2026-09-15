import 'package:flutter/material.dart';
enum Severidade { critico, alto, medio, baixo }

extension SeveridadeTexto on Severidade {
  String get rotulo => switch (this) {
        Severidade.critico => 'Crítico',
        Severidade.alto => 'Alto',
        Severidade.medio => 'Médio',
        Severidade.baixo => 'Baixo',
      };
}

enum StatusIncidente { aberto, emAndamento, resolvido }

extension StatusTexto on StatusIncidente {
  String get rotulo => switch (this) {
        StatusIncidente.aberto => 'Aberto',
        StatusIncidente.emAndamento => 'Em andamento',
        StatusIncidente.resolvido => 'Resolvido',
      };
}

enum TipoIncidente { phishing, malware, acessoNaoAutorizado, ddos, outro }

extension TipoTexto on TipoIncidente {
  String get rotulo => switch (this) {
        TipoIncidente.phishing => 'Phishing',
        TipoIncidente.malware => 'Malware',
        TipoIncidente.acessoNaoAutorizado => 'Acesso não autorizado',
        TipoIncidente.ddos => 'DDoS',
        TipoIncidente.outro => 'Outro',
      };
}

class Incidente {
  final String id;
  final String titulo;
  final TipoIncidente tipo;
  final Severidade severidade;
  final StatusIncidente status;
  final DateTime dataAbertura;
  final String? responsavel;

  const Incidente({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.severidade,
    required this.status,
    required this.dataAbertura,
    this.responsavel,
  });

  String get tempoDecorrido {
    final diferenca = DateTime.now().difference(dataAbertura);

    if (diferenca.inMinutes < 60) {
      return 'há ${diferenca.inMinutes}min';
    }
    if (diferenca.inHours < 24) {
      return 'há ${diferenca.inHours}h';
    }
    return 'há ${diferenca.inDays} ${diferenca.inDays == 1 ? "dia" : "dias"}';
  }
}

final List<Incidente> incidentes = [
  Incidente(
    id: 'INC-1042',
    titulo: 'Varredura de portas detectada na DMZ',
    tipo: TipoIncidente.acessoNaoAutorizado,
    severidade: Severidade.alto,
    status: StatusIncidente.aberto,
    dataAbertura: DateTime.now().subtract(const Duration(minutes: 8)),
  ),
  Incidente(
    id: 'INC-1041',
    titulo: 'Múltiplas tentativas de login em conta administrativa',
    tipo: TipoIncidente.acessoNaoAutorizado,
    severidade: Severidade.critico,
    status: StatusIncidente.emAndamento,
    dataAbertura: DateTime.now().subtract(const Duration(minutes: 35)),
    responsavel: 'Marina Duarte',
  ),
  Incidente(
    id: 'INC-1039',
    titulo: 'Anexo malicioso identificado em e-mail corporativo',
    tipo: TipoIncidente.phishing,
    severidade: Severidade.alto,
    status: StatusIncidente.emAndamento,
    dataAbertura: DateTime.now().subtract(const Duration(hours: 2)),
    responsavel: 'Rafael Nogueira',
  ),
  Incidente(
    id: 'INC-1037',
    titulo: 'Certificado TLS do portal expirado',
    tipo: TipoIncidente.outro,
    severidade: Severidade.medio,
    status: StatusIncidente.aberto,
    dataAbertura: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  Incidente(
    id: 'INC-1035',
    titulo: 'Ransomware bloqueado em estação de trabalho',
    tipo: TipoIncidente.malware,
    severidade: Severidade.critico,
    status: StatusIncidente.resolvido,
    dataAbertura: DateTime.now().subtract(const Duration(hours: 9)),
    responsavel: 'Camila Prado',
  ),
  Incidente(
    id: 'INC-1033',
    titulo: 'Pico de tráfego UDP no gateway de borda',
    tipo: TipoIncidente.ddos,
    severidade: Severidade.alto,
    status: StatusIncidente.resolvido,
    dataAbertura: DateTime.now().subtract(const Duration(hours: 20)),
    responsavel: 'Rafael Nogueira',
  ),
  Incidente(
    id: 'INC-1030',
    titulo: 'Login bem-sucedido a partir de país não usual',
    tipo: TipoIncidente.acessoNaoAutorizado,
    severidade: Severidade.critico,
    status: StatusIncidente.emAndamento,
    dataAbertura: DateTime.now().subtract(const Duration(days: 1)),
    responsavel: 'Marina Duarte',
  ),
  Incidente(
    id: 'INC-1028',
    titulo: 'Página de phishing clonando o portal de RH',
    tipo: TipoIncidente.phishing,
    severidade: Severidade.medio,
    status: StatusIncidente.resolvido,
    dataAbertura: DateTime.now().subtract(const Duration(days: 2)),
    responsavel: 'Bruno Tavares',
  ),
  Incidente(
    id: 'INC-1025',
    titulo: 'Software não homologado instalado em notebook',
    tipo: TipoIncidente.outro,
    severidade: Severidade.baixo,
    status: StatusIncidente.aberto,
    dataAbertura: DateTime.now().subtract(const Duration(days: 4)),
  ),
  Incidente(
    id: 'INC-1021',
    titulo: 'Adware detectado em máquina do setor comercial',
    tipo: TipoIncidente.malware,
    severidade: Severidade.baixo,
    status: StatusIncidente.resolvido,
    dataAbertura: DateTime.now().subtract(const Duration(days: 7)),
    responsavel: 'Camila Prado',
  ),
];

IconData iconePara(Severidade severidade) {
  switch (severidade) {
    case Severidade.critico:
      return Icons.error;
    case Severidade.alto:
      return Icons.warning_amber;
    case Severidade.medio:
      return Icons.info_outline;
    case Severidade.baixo:
      return Icons.check_circle_outline;
  }
}

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
                Icon(iconePara(incidente.severidade)),
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
            const SizedBox(height: 8),
            Text('#${incidente.id} · ${incidente.tipo.rotulo}'),
            const SizedBox(height: 4),
            Text(
              '${incidente.severidade.rotulo} · ${incidente.status.rotulo}',
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: incidentes
              .map((incidente) => IncidenteCard(incidente: incidente))
              .toList(),
        ),
      ),
    );
  }
}
