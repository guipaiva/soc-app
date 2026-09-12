import 'package:flutter/material.dart';



enum TipoIncidente { phishing, malware, acessoNaoAutorizado, ddos, outro }
enum Severidade { critico, alto, medio, baixo }
enum StatusIncidente { aberto, emAndamento, resolvido }

class Incidente {
  final String identificador;
  final String titulo;
  final TipoIncidente tipo;
  final Severidade severidade;
  final StatusIncidente status;
  final DateTime abertoEm;
  final String? responsavel; // null = sem responsável


  Incidente({
    required this.identificador,
    required this.titulo,
    required this.tipo,
    required this.severidade,
    required this.status,
    required this.abertoEm,
    required this.responsavel,
  });

  String get tempoDecorrido {
    final diff = DateTime.now().difference(abertoEm);
    if (diff.inDays > 0) {
      return '${diff.inDays} dias';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} horas';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutos';
    } else {
      return 'menos de um minuto';
    }
}
}


List<Incidente> incidentes = [
  Incidente(
    identificador: 'INC001',
    titulo: 'Phishing em e-mail corporativo',
    tipo: TipoIncidente.phishing,
    severidade: Severidade.alto,
    status: StatusIncidente.aberto,
    abertoEm: DateTime.now().subtract(const Duration(hours: 2)),
    responsavel: null,
  ),
  Incidente(
    identificador: 'INC002',
    titulo: 'Malware detectado em estação de trabalho',
    tipo: TipoIncidente.malware,
    severidade: Severidade.critico,
    status: StatusIncidente.emAndamento,
    abertoEm: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    responsavel: 'João Silva',
  ),
  Incidente(
    identificador: 'INC003',
    titulo: 'Tentativa de acesso não autorizado',
    tipo: TipoIncidente.acessoNaoAutorizado,
    severidade: Severidade.medio,
    status: StatusIncidente.resolvido,
    abertoEm: DateTime.now().subtract(const Duration(days: 5, hours: 6)),
    responsavel: 'Maria Oliveira',
  ),
  Incidente(
    identificador: 'INC004',
    titulo: 'Ataque DDoS',
    tipo: TipoIncidente.ddos,
    severidade: Severidade.critico,
    status: StatusIncidente.aberto,
    abertoEm: DateTime.now().subtract(const Duration(hours: 1)),
    responsavel: null,
    ),
  Incidente(
    identificador: 'INC005',
    titulo: 'Ataque DDoS no Servidor de Aplicações',
    tipo: TipoIncidente.ddos,
    severidade: Severidade.critico,
    status: StatusIncidente.aberto,
    abertoEm: DateTime.now().subtract(const Duration(minutes: 15)),
    responsavel: null,
  ),
  Incidente(
    identificador: 'INC006',
    titulo: 'Ataque DDoS no Servidor de Banco de Dados',
    tipo: TipoIncidente.acessoNaoAutorizado,
    severidade: Severidade.critico,
    status: StatusIncidente.emAndamento,
    abertoEm: DateTime.now().subtract(const Duration(minutes: 30)),
    responsavel: 'Carlos Pereira',
  )
];

IconData inconePorSeveridade(Severidade severidade) {
  switch (severidade) {
    case Severidade.critico:
      return Icons.error;
    case Severidade.alto:
      return Icons.warning;
    case Severidade.medio:
      return Icons.info;
    case Severidade.baixo:
      return Icons.check_circle;
  }
}


class IncidentCard extends StatelessWidget {
  final Incidente incidente;

  const IncidentCard({super.key, required this.incidente});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(inconePorSeveridade(incidente.severidade)),
        title: Text(incidente.titulo),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${incidente.tipo.name}'),
            Text('Severidade: ${incidente.severidade.name}'),
            Text('Status: ${incidente.status.name}'),
            Text('Aberto em: ${incidente.abertoEm}'),
            Text('Responsável: ${incidente.responsavel ?? 'Sem responsável'}'),
            Text('Tempo decorrido: ${incidente.tempoDecorrido}'),
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
      home: Scaffold(
        appBar: AppBar(title: const Text('Central de Incidentes')),
        body: ListView(
          children: incidentes.map((i) => IncidentCard(incidente: i)).toList(),
        ),
      ),
    );
  }
}


