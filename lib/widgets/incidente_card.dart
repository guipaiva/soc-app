import 'package:flutter/material.dart';

import '../models/incidente.dart';

IconData iconeDaSeveridade(Severidade severidade) {
  switch (severidade) {
    case Severidade.critico:
      return Icons.report;
    case Severidade.alto:
      return Icons.warning;
    case Severidade.medio:
      return Icons.info;
    case Severidade.baixo:
      return Icons.low_priority;
  }
}

Color corDaSeveridade(Severidade severidade) {
  switch (severidade) {
    case Severidade.critico:
      return Colors.red;
    case Severidade.alto:
      return Colors.orange;
    case Severidade.medio:
      return Colors.amber;
    case Severidade.baixo:
      return Colors.blue;
  }
}

String textoDaSeveridade(Severidade severidade) {
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

String textoDoStatus(Status status) {
  switch (status) {
    case Status.aberto:
      return 'Aberto';
    case Status.emAndamento:
      return 'Em andamento';
    case Status.resolvido:
      return 'Resolvido';
  }
}

Color corDoStatus(Status status) {
  switch (status) {
    case Status.aberto:
      return Colors.red;
    case Status.emAndamento:
      return Colors.amber;
    case Status.resolvido:
      return Colors.green;
  }
}

class IncidenteCard extends StatelessWidget {
  final Incidente incidente;

  const IncidenteCard({super.key, required this.incidente});

  @override
  Widget build(BuildContext context) {
    final corSev = corDaSeveridade(incidente.severidade);
    final tituloSev = textoDaSeveridade(incidente.severidade);
    final textoStat = textoDoStatus(incidente.status);
    final corStat = corDoStatus(incidente.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                    label: Text(
                        tituloSev,
                        style: TextStyle(
                        color: corSev,
                        fontWeight: FontWeight.bold,
                        ),
                    ),
                    backgroundColor: corSev.withValues(alpha: 0.15),
                    side: BorderSide(
                        color: corSev,
                    ),
                ),
                Spacer(),
                Text(incidente.abertoHa),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 4),
            Row(
                children: [
                    Icon(iconeDaSeveridade(incidente.severidade), color: corSev),
                    Text(' ${incidente.titulo}', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: corSev,
                        ),
                    ),
                ],
            ),
            Row(
                children: [
                    Text('#${incidente.id} · ${incidente.tipo}', style: TextStyle(color: Colors.grey)),
                ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                    label: Text(
                        textoStat,
                        style: TextStyle(
                            color: corStat,
                        ),
                    ),
                    backgroundColor: Colors.grey.withValues(alpha: 0.15),
                    side: BorderSide(
                        color: Colors.grey,
                    ),
                ),
                Spacer(),
                Text(incidente.responsavel ?? 'Sem responsável'),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
