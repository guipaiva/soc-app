import 'package:flutter/material.dart';
//Kauan - https://share.gemini.google/846ClN6vmRok

//Lista de Incidentes
final List<Incidente> listaIncidentes = [
  Incidente(
    id: 'INC-1001',
    titulo: 'negação de serviço',
    tipo: TipodeIncidente.ddos,
    severidade: Severidade.critico,
    status: StatusIncidente.emAndamento,
    dataAbertura: DateTime.now().subtract(const Duration(minutes: 25)),
    responsavel: 'Fabio',
  ),
  Incidente(
    id: 'INC-1002',
    titulo: 'força bruta',
    tipo: TipodeIncidente.acessoNaoAutorizado,
    severidade: Severidade.alto,
    status: StatusIncidente.aberto,
    dataAbertura: DateTime.now().subtract(const Duration(hours: 3)),
    responsavel: null, 
  ),
  Incidente(
    id: 'INC-1003',
    titulo: 'phishing',
    tipo: TipodeIncidente.phishing,
    severidade: Severidade.alto,
    status: StatusIncidente.resolvido,
    dataAbertura: DateTime.now().subtract(const Duration(days: 2)),
    responsavel: 'Thiago',
  ),
  Incidente(
    id: 'INC-1004',
    titulo: 'Trojan',
    tipo: TipodeIncidente.malware,
    severidade: Severidade.medio,
    status: StatusIncidente.emAndamento,
    dataAbertura: DateTime.now().subtract(const Duration(hours: 6)),
    responsavel: 'Carlos',
  ),
  Incidente(
    id: 'INC-1005',
    titulo: 'Certificado prestes a expirar',
    tipo: TipodeIncidente.outro,
    severidade: Severidade.baixo,
    status: StatusIncidente.aberto,
    dataAbertura: DateTime.now().subtract(const Duration(minutes: 50)),
    responsavel: null, 
  ),
  Incidente(
    id: 'INC-1006',
    titulo: 'Sniffing',
    tipo: TipodeIncidente.acessoNaoAutorizado,
    severidade: Severidade.medio,
    status: StatusIncidente.resolvido,
    dataAbertura: DateTime.now().subtract(const Duration(days: 5)),
    responsavel: 'Melissa',
  ),
];








// Lista de Possibilidades
enum TipodeIncidente {
  phishing("Phishing"),
  malware("Malware"),
  acessoNaoAutorizado("Acesso não Autorizado"),
  ddos("DDoS"),
  outro("Outro");

  final String rotulo;
  const TipodeIncidente(this.rotulo);
}

enum Severidade {
  critico("Crítico", Icons.dangerous, Colors.red),
  alto("Alto", Icons.warning_amber_rounded, Colors.orange),
  medio("Médio", Icons.info_outline, Colors.amber),
  baixo("Baixo", Icons.shield_outlined, Colors.blue);

  final String rotulo;
  final IconData icone;
  final Color cor;

  const Severidade(this.rotulo, this.icone, this.cor);
}

enum StatusIncidente {
  aberto("Aberto"),
  emAndamento("Em andamento"),
  resolvido("Resolvido");

  final String rotulo;
  const StatusIncidente(this.rotulo);
}

// Classe de Dados
class Incidente {
  // Declarando Variaveis
  final String id;
  final String titulo;
  final TipodeIncidente tipo;
  final Severidade severidade;
  final StatusIncidente status;
  final DateTime dataAbertura;
  final String? responsavel;

  // Construotr
  const Incidente({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.severidade,
    required this.status,
    required this.dataAbertura,
    this.responsavel
  });

  //Métodos da Classe
  String get tempoDecorrido {
    final diferenca = DateTime.now().difference(dataAbertura);

    if (diferenca.inDays >= 1) {
      return "há ${diferenca.inDays} ${diferenca.inDays == 1 ? "dia" : "dias"}";
    } else if (diferenca.inHours >= 1) {
      return "há ${diferenca.inHours} h";
    } else {
      final minutos = diferenca.inMinutes;
      return "há ${minutos <= 0 ? 1: minutos} min";
    }
  }
}

// Classe de Widgets
class IncidenteCard extends StatelessWidget {
  final Incidente incidente;

  const IncidenteCard({super.key, required this.incidente});

  @override
  Widget build(BuildContext context) {
    final severidade = incidente.severidade;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,

      child: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Icon(
                  severidade.icone,
                  color: severidade.cor,
                  size: 24,
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    incidente.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "#${incidente.id} · ${incidente.tipo.rotulo}",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
  

              )
             
            ),

            Row(
              children: [
                _StatusChip(
                  rotulo: "Severidade: ${severidade.rotulo}",
                  textColor: severidade.cor
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  rotulo: "Status: ${incidente.status.rotulo}",
                  textColor: Colors.black,
                )
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Text(
                  incidente.responsavel ?? "Sem Responsavel",
                  style: TextStyle(
                    fontStyle: incidente.responsavel == null ? FontStyle.italic : FontStyle.normal,
                    color: incidente.responsavel == null ? Colors.grey[500] : Colors.black,
                    fontSize: 13,
                  ),
                ),
                Text( 
                  incidente.tempoDecorrido,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                )
              ]
            ),
          ],
        )
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String rotulo;
  final Color textColor;

  const _StatusChip({required this.rotulo, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        rotulo,
        style: TextStyle(fontSize: 12, color: textColor)
      )
    );
  }
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
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: listaIncidentes
          .map((incidente) => IncidenteCard(incidente: incidente))
          .toList(),
        )
      ),
    );
  }
}

void main() {
  runApp(const CentralIncidentesApp());
}