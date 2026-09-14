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
          children: incidentes.map((i) => IncidenteCard(incidente: i)).toList(),
        ),
      ),
    );
  }
}

final Map<String, IconData> _iconesPorSeveridade = {
  'CRÍTICO': Icons.dangerous,
  'ALTO': Icons.warning_amber,
  'MÉDIO': Icons.info,
  'BAIXO': Icons.check_circle_outline,
};

IconData iconePorSeveridade(String severidade) {
  return _iconesPorSeveridade[severidade] ?? Icons.help_outline;
}

class Incidente {
  final String id;
  final String titulo;
  final String tipo;
  final String severidade;
  final String status;
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

final List<Incidente> incidentes = [
  Incidente(
    id: 'INC-1042',
    titulo: 'Tentativa de phishing em massa',
    tipo: 'Phishing',
    severidade: 'CRÍTICO',
    status: 'Aberto',
    abertoEm: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  Incidente(
    id: 'INC-1043',
    titulo: 'Login suspeito fora do horário',
    tipo: 'Acesso não autorizado',
    severidade: 'ALTO',
    status: 'Em andamento',
    abertoEm: DateTime.now().subtract(const Duration(hours: 3)),
    responsavel: 'Ana Ribeiro',
  ),
  Incidente(
    id: 'INC-1044',
    titulo: 'Certificado TLS expirado no gateway',
    tipo: 'Outro',
    severidade: 'MÉDIO',
    status: 'Resolvido',
    abertoEm: DateTime.now().subtract(const Duration(days: 2)),
    responsavel: 'Bruno Costa',
  ),
  Incidente(
    id: 'INC-1045',
    titulo: 'Varredura de portas na DMZ',
    tipo: 'Outro',
    severidade: 'BAIXO',
    status: 'Aberto',
    abertoEm: DateTime.now().subtract(const Duration(minutes: 40)),
  ),
  Incidente(
    id: 'INC-1046',
    titulo: 'Ransomware detectado em estação',
    tipo: 'Malware',
    severidade: 'CRÍTICO',
    status: 'Em andamento',
    abertoEm: DateTime.now().subtract(const Duration(hours: 1)),
    responsavel: 'Carla Souza',
  ),
  Incidente(
    id: 'INC-1047',
    titulo: 'Pico de tráfego suspeito no servidor web',
    tipo: 'DDoS',
    severidade: 'ALTO',
    status: 'Resolvido',
    abertoEm: DateTime.now().subtract(const Duration(days: 1)),
    responsavel: 'Diego Fernandes',
  ),
  Incidente(
    id: 'INC-1048',
    titulo: 'E-mail com link malicioso reportado',
    tipo: 'Phishing',
    severidade: 'MÉDIO',
    status: 'Aberto',
    abertoEm: DateTime.now().subtract(const Duration(minutes: 5)),
    responsavel: 'Ana Ribeiro',
  ),
  Incidente(
    id: 'INC-1049',
    titulo: 'Acesso a arquivo confidencial fora do perfil',
    tipo: 'Acesso não autorizado',
    severidade: 'BAIXO',
    status: 'Resolvido',
    abertoEm: DateTime.now().subtract(const Duration(days: 5)),
    responsavel: 'Bruno Costa',
  ),
];

class IncidenteCard extends StatelessWidget {
  final Incidente incidente;

  const IncidenteCard({super.key, required this.incidente});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(iconePorSeveridade(incidente.severidade)),
                const SizedBox(width: 8),
                Text(incidente.titulo),
              ],
            ),
            const SizedBox(height: 8),
            Text('#${incidente.id} · ${incidente.tipo}'),
            const SizedBox(height: 8),
            Text('${incidente.severidade} · ${incidente.status}'),
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