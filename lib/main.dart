import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Tipos possíveis de incidente
enum TipoIncidente { phishing, malware, acessoNaoAutorizado, ddos, outro }

// Nível de severidade do incidente
enum Severidade { critico, alto, medio, baixo }

// Situação atual do incidente
enum StatusIncidente { aberto, emAndamento, resolvido }

// Transforma o enum em texto para mostrar na tela
String textoTipo(TipoIncidente tipo) {
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

String textoSeveridade(Severidade severidade) {
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

String textoStatus(StatusIncidente status) {
  switch (status) {
    case StatusIncidente.aberto:
      return 'Aberto';
    case StatusIncidente.emAndamento:
      return 'Em andamento';
    case StatusIncidente.resolvido:
      return 'Resolvido';
  }
}

// Um ícone diferente para cada severidade, decidido aqui e só aqui
IconData iconeDaSeveridade(Severidade severidade) {
  switch (severidade) {
    case Severidade.critico:
      return Icons.dangerous;
    case Severidade.alto:
      return Icons.warning_amber_rounded;
    case Severidade.medio:
      return Icons.info_outline;
    case Severidade.baixo:
      return Icons.check_circle_outline;
  }
}

class Incidente {
  final String id;
  final String titulo;
  final TipoIncidente tipo;
  final Severidade severidade;
  final StatusIncidente status;
  final DateTime abertura;
  final String? responsavel; // null quando ainda ninguém pegou o caso

  Incidente({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.severidade,
    required this.status,
    required this.abertura,
    this.responsavel,
  });

  // Calcula há quanto tempo o incidente foi aberto
  String get tempoAberto {
    Duration diferenca = DateTime.now().difference(abertura);

    if (diferenca.inMinutes < 60) {
      return 'há ${diferenca.inMinutes}min';
    } else if (diferenca.inHours < 24) {
      return 'há ${diferenca.inHours}h';
    } else {
      return 'há ${diferenca.inDays} dias';
    }
  }
}

// Lista de incidentes que vai aparecer na tela
List<Incidente> listaDeIncidentes = [
  Incidente(
    id: 'INC-1042',
    titulo: 'Tentativa de phishing em massa',
    tipo: TipoIncidente.phishing,
    severidade: Severidade.critico,
    status: StatusIncidente.aberto,
    abertura: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  Incidente(
    id: 'INC-1043',
    titulo: 'Certificado SSL expirado no portal',
    tipo: TipoIncidente.outro,
    severidade: Severidade.baixo,
    status: StatusIncidente.resolvido,
    abertura: DateTime.now().subtract(const Duration(days: 2)),
    responsavel: 'Ana Souza',
  ),
  Incidente(
    id: 'INC-1044',
    titulo: 'Login suspeito fora do horário comercial',
    tipo: TipoIncidente.acessoNaoAutorizado,
    severidade: Severidade.alto,
    status: StatusIncidente.emAndamento,
    abertura: DateTime.now().subtract(const Duration(hours: 3)),
    responsavel: 'Carlos Lima',
  ),
  Incidente(
    id: 'INC-1045',
    titulo: 'Varredura de portas detectada no firewall',
    tipo: TipoIncidente.outro,
    severidade: Severidade.medio,
    status: StatusIncidente.aberto,
    abertura: DateTime.now().subtract(const Duration(minutes: 40)),
  ),
  Incidente(
    id: 'INC-1046',
    titulo: 'Malware identificado em estação de trabalho',
    tipo: TipoIncidente.malware,
    severidade: Severidade.critico,
    status: StatusIncidente.emAndamento,
    abertura: DateTime.now().subtract(const Duration(hours: 5)),
    responsavel: 'Beatriz Nunes',
  ),
  Incidente(
    id: 'INC-1047',
    titulo: 'Ataque DDoS ao servidor web principal',
    tipo: TipoIncidente.ddos,
    severidade: Severidade.alto,
    status: StatusIncidente.resolvido,
    abertura: DateTime.now().subtract(const Duration(days: 1)),
    responsavel: 'Diego Alves',
  ),
];

// Widget que desenha um cartão para um incidente
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
                Icon(iconeDaSeveridade(incidente.severidade)),
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
            Text('#${incidente.id} · ${textoTipo(incidente.tipo)}'),
            const SizedBox(height: 4),
            Text(
              'Severidade: ${textoSeveridade(incidente.severidade)} · Status: ${textoStatus(incidente.status)}',
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(incidente.responsavel ?? 'Sem responsável'),
                Text(incidente.tempoAberto),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Central de Incidentes',
      home: Scaffold(
        appBar: AppBar(title: const Text('Central de Incidentes')),
        body: ListView(
          children: listaDeIncidentes
              .map((i) => IncidenteCard(incidente: i))
              .toList(),
        ),
      ),
    );
  }
}
