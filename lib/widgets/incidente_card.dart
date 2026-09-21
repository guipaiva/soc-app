import 'package:flutter/material.dart';

import 'package:central_incidentes/models/incidente.dart';

String textoDaSeveridade(Severidade severidade) => switch (severidade) {
      Severidade.critico => 'Crítico',
      Severidade.alto => 'Alto',
      Severidade.medio => 'Médio',
      Severidade.baixo => 'Baixo',
    };

Color corDaSeveridade(Severidade severidade) => switch (severidade) {
      Severidade.critico => Colors.red,
      Severidade.alto => Colors.orange,
      Severidade.medio => Colors.amber,
      Severidade.baixo => Colors.blue,
    };

IconData iconeDaSeveridade(Severidade severidade) => switch (severidade) {
      Severidade.critico => Icons.report,
      Severidade.alto => Icons.warning,
      Severidade.medio => Icons.info,
      Severidade.baixo => Icons.low_priority,
    };

String textoDoStatus(StatusIncidente status) => switch (status) {
      StatusIncidente.aberto => 'Aberto',
      StatusIncidente.emAndamento => 'Em andamento',
      StatusIncidente.resolvido => 'Resolvido',
    };

Color corDoStatus(StatusIncidente status) => switch (status) {
      StatusIncidente.aberto => Colors.red,
      StatusIncidente.emAndamento => Colors.amber,
      StatusIncidente.resolvido => Colors.green,
    };

class IncidenteCard extends StatelessWidget {
  final Incidente incidente;

  const IncidenteCard({super.key, required this.incidente});

  @override
  Widget build(BuildContext context) {
    final corSeveridade = corDaSeveridade(incidente.severidade);
    final corStatus = corDoStatus(incidente.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(textoDaSeveridade(incidente.severidade)),
                  backgroundColor: corSeveridade.withValues(alpha: 0.15),
                  side: BorderSide(color: corSeveridade),
                ),
                Text(incidente.abertoHa),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  iconeDaSeveridade(incidente.severidade),
                  color: corSeveridade,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    incidente.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '#${incidente.id} · ${incidente.tipo}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    textoDoStatus(incidente.status),
                    style: TextStyle(color: corStatus),
                  ),
                  backgroundColor: Colors.grey.shade200,
                ),
                Text(incidente.responsavel ?? 'Sem responsável'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
