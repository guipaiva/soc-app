import 'package:flutter/material.dart';
import 'widgets/incident_cards.dart';

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



class Incidente {
  final String id;
  final String titulo;
  final String tipo;
  final String severidade;
  final String status;
  final DateTime abertoEm;
  final String? responsavel;

  const Incidente({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.severidade,
    required this.status,
    required this.abertoEm,
    this.responsavel,
  });

  String get abertoHa {
    final decorrido = DateTime.now().difference(abertoEm);
    if (decorrido.inMinutes < 60) {
      return 'há ${decorrido.inMinutes}min';
    }
    if (decorrido.inHours < 24) {
      return 'há ${decorrido.inHours}h';
    }
    final dias = decorrido.inDays;
    return dias == 1 ? 'há 1 dia' : 'há $dias dias';
  }
}

IconData iconeDaSeveridade(String severidade) {
  switch (severidade) {
    case 'Crítico':
      return Icons.report;
    case 'Alto':
      return Icons.warning;
    case 'Médio':
      return Icons.info;
    default:
      return Icons.low_priority;
  }
}

class IncidenteCard extends StatelessWidget {
  final Incidente incidente;

  const IncidenteCard({super.key, required this.incidente});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.teal,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
  ),
  home: Scaffold(
    appBar: AppBar(title: const Text('Incidentes')),
    body: ListView(
      children: incidentes.map((i) => IncidenteCard(incidente: i)).toList(),
    ),
  ),
);
  }
}

final agora = DateTime.now();

final List<Incidente> incidentes = [
  Incidente(
    id: 'INC-1045',
    titulo: 'Login falho repetido — conta admin',
    tipo: 'Acesso não autorizado',
    severidade: 'Crítico',
    status: 'Aberto',
    abertoEm: agora.subtract(const Duration(minutes: 15)),
  ),
  Incidente(
    id: 'INC-1044',
    titulo: 'Acesso fora do horário — VPN corporativa',
    tipo: 'Acesso não autorizado',
    severidade: 'Crítico',
    status: 'Aberto',
    abertoEm: agora.subtract(const Duration(minutes: 40)),
    responsavel: 'Ana Souza',
  ),
  Incidente(
    id: 'INC-1042',
    titulo: 'Tentativa de phishing — portal de RH',
    tipo: 'Phishing',
    severidade: 'Alto',
    status: 'Em andamento',
    abertoEm: agora.subtract(const Duration(hours: 3)),
    responsavel: 'Ana Souza',
  ),
  Incidente(
    id: 'INC-1039',
    titulo: 'Malware detectado — estação FIN-07',
    tipo: 'Malware',
    severidade: 'Alto',
    status: 'Em andamento',
    abertoEm: agora.subtract(const Duration(days: 1, hours: 2)),
    responsavel: 'Carlos Lima',
  ),
  Incidente(
    id: 'INC-1031',
    titulo: 'Picos de tráfego — API pública',
    tipo: 'DDoS',
    severidade: 'Médio',
    status: 'Resolvido',
    abertoEm: agora.subtract(const Duration(days: 2, hours: 5)),
    responsavel: 'Ana Souza',
  ),
  Incidente(
    id: 'INC-1027',
    titulo: 'Certificado TLS expirado — intranet',
    tipo: 'Outro',
    severidade: 'Baixo',
    status: 'Resolvido',
    abertoEm: agora.subtract(const Duration(days: 4)),
    responsavel: 'Carlos Lima',
  ),
];

void main() {
  runApp(
    MaterialApp(
      title: 'Central de Incidentes',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[700],
          title: const Text('Central de Incidentes'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: incidentes
              .map((incidente) => IncidenteCard(incidente: incidente))
              .toList(),
        ),
      ),
    ),
  );
}
