import 'package:flutter/material.dart';

class Incidente {
  final String indentificador;
  final String titulo;
  final String tipo;
  final String severidade;
  final String status;
  final DateTime dataAbertura;
  final String? responsavel;

  Incidente({
    required this.indentificador,
    required this.titulo,
    required this.tipo,
    required this.severidade,
    required this.status,
    required this.dataAbertura,
    this.responsavel = 'Sem responsável',
  });

  String get dataAberto {
    final diferenca = DateTime.now().difference(dataAbertura);

    if (diferenca.inMinutes < 60) {
      return 'há ${diferenca.inMinutes}min';
    } else if (diferenca.inHours < 24) {
      return 'há ${diferenca.inHours}h';
    } else {
      return 'há ${diferenca.inDays} dias';
    }
  }
}


void main() {
  List<String> listaIncidentes = [
    'INC-2312;Campanha de phishing;Phishing;MÉDIO;Em andamento;2026-08-25 14:00:00;Rebecca',
    'INC-2205;Ataque DDoS contra serviços da rede;DDOS;ALTO;Em andamento;2026-09-10 13:43:00;Leila',
    'INC-3011;Malware detectado;Malware;CRÍTICO;Resolvido;2026-05-11 16:50:00;Carlos',
    'INC-2002;Tentativa de acesso não autorizado;Acesso não autorizado;BAIXO;Aberto;2026-03-16 22:09:00;Pedro',
    'INC-1298;Certificado de segurança expirado;Outro;BAIXO;Resolvido;2025-02-11 12:24:00',
    'INC-1098;Varredura suspeita de portas;Outro;MÉDIO;Aberto;2026-11-14 07:57:00;Luigi',
  ];

    var incidente = Map<String, Incidente>();

    for (var evento in listaIncidentes) {
      var linha = evento.split(';');
      var id = linha[0];

      if (!incidente.containsKey(id)) {
        incidente[id] = Incidente(indentificador: linha[0],
        titulo: linha[1], 
        tipo: linha[2], 
        severidade: linha[3], 
        status: linha[4], 
        dataAbertura: DateTime.parse(linha[5]),
        responsavel: linha.length > 6 ? linha[6] : null
        );
      }
    }

    runApp(CentralIncidentesApp(incidentes: incidente));
}

class CentralIncidentesApp extends StatelessWidget {
  const CentralIncidentesApp({super.key, required this.incidentes});

  final Map<String, Incidente> incidentes;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Central de Incidentes',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[700],
          title: const Text('Central de Incidentes')
        ),
        body: ListView(
          children: incidentes.values.map((inc) => IncidenteCard(incidente: inc)).toList(),
        ),
      ),
    );
  }
}

class IncidenteCard extends StatelessWidget {
  final Incidente incidente;

  const IncidenteCard({super.key, required this.incidente});

  Icon _iconePorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'aberto':
        return const Icon(Icons.error_outline, color: Colors.red);
      case 'em andamento':
        return const Icon(Icons.autorenew, color: Colors.orange);
      case 'resolvido':
        return const Icon(Icons.check_circle, color: Colors.green);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _iconePorStatus(incidente.status),
                SizedBox(width: 5,),
                Text(incidente.titulo)
              ],
            ),
            Row(
              children: [
                Text('#${incidente.indentificador} · ${incidente.tipo} ')
              ],
            ),
            Row(
              children: [
                Text(incidente.severidade),
                SizedBox(width: 35,),
                Text(incidente.status)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(incidente.responsavel ?? 'Sem responsável'),
                Text(incidente.dataAberto)
              ],
            )
          ],
        )
      )
    );
  }
}