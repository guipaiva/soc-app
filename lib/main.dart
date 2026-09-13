import 'package:flutter/material.dart';


class Incidente {
  final String identificador; //INC-1042
  final String tipo; //phishing, malware, acesso não autorizado, DDoS, outro
  final String titulo;
  final String severidade; //crítico, alto, médio, baixo
  final String status; //aberto, em andamento, resolvido
  final DateTime data_criacao = DateTime.now();
  final String? responsavel;

  Incidente({
    required this.identificador,
    required this.tipo,
    required this.titulo,
    required this.severidade,
    this.status = 'aberto',
    this.responsavel,
  });

  String getResponsavel() => this.responsavel ?? 'Sem responsável';

  String get tempoDeCriacao {
    //A data de abertura é guardada como DateTime; 
    //a diferença até agora (DateTime.now()) é um Duration, 
    //que sabe se converter em minutos, horas ou dias. 
    //Qual unidade mostrar depende do tamanho da diferença.
    return 'há 1 min';
  }
}

class IncidenteCard extends StatelessWidget{
  final Incidente incidente;
  final IconData icone;

  IncidenteCard({
    super.key,
    required this.incidente, 
    required this.icone
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [Icon(icone), Text(' ${incidente.titulo}')]),
            Row(children: [Text('${incidente.identificador} · ${incidente.tipo}')]),
            Row(children: [Text('${incidente.severidade} · ${incidente.status}')]),
            Row(children: [
              Text('${incidente.getResponsavel()}'),
              Spacer(),
              Text('${incidente.tempoDeCriacao}')
            ]),
          ]
        ),
      ),
    );
  }
}

Incidente incidenteTeste = Incidente(
    identificador: 'INC-42',
    tipo: 'DDOS',
    titulo: 'DDOS NA CENTRAL',
    severidade: 'crítico',
    status: 'aberto',
    responsavel: 'Lucas'
);
Incidente incidenteTeste2 = Incidente(
    identificador: 'INC-43',
    tipo: 'Malware',
    titulo: 'Malware no PC do Jhonathan',
    severidade: 'baixo',
    status: 'aberto',
    // responsavel: 'Mateus'
);
Incidente incidenteTeste3 = Incidente(
    identificador: 'INC-44',
    tipo: 'Phishing',
    titulo: 'Phishing de Login',
    severidade: 'alto',
    status: 'resolvido',
    responsavel: 'Mateus'
);
Incidente incidenteTeste4 = Incidente(
    identificador: 'INC-45',
    tipo: 'Acesso não autorizado',
    titulo: 'Acesso ao Dash de conta sem privilégio',
    severidade: 'médio',
    status: 'em andamento',
    responsavel: 'João da Silva'
);
Incidente incidenteTeste5 = Incidente(
    identificador: 'INC-46',
    tipo: 'Outro',
    titulo: 'Provável sniffer na rede',
    severidade: 'alto',
    status: 'aberto',
    responsavel: 'Luana'
);
Incidente incidenteTeste6 = Incidente(
    identificador: 'INC-47',
    tipo: 'SQL Injection',
    titulo: 'Vulnerabilidade no ambiente de testes',
    severidade: 'baixo',
    status: 'resolvido',
    responsavel: 'Juliano'
);

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
        appBar: AppBar(
          title: const Text('Central de Incidentes'), 
          centerTitle: true
        ),
        backgroundColor: Colors.blue,
        body: Column(children: [
          IncidenteCard(incidente: incidenteTeste, icone: Icons.local_fire_department),
          IncidenteCard(incidente: incidenteTeste2, icone: Icons.local_fire_department),
          IncidenteCard(incidente: incidenteTeste3, icone: Icons.local_fire_department),
          IncidenteCard(incidente: incidenteTeste4, icone: Icons.local_fire_department),
          IncidenteCard(incidente: incidenteTeste5, icone: Icons.local_fire_department),
          IncidenteCard(incidente: incidenteTeste6, icone: Icons.local_fire_department),
          ]),
      ),
    );
  }
}
