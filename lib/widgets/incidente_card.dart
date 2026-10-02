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

Color corDoStatus(StatusIncidente status) {
  switch (status) {
    case StatusIncidente.aberto:
      return Colors.red;
    case StatusIncidente.emAndamento:
      return Colors.amber;
    case StatusIncidente.resolvido:
      return Colors.green;
  }
}

class IncidenteCard extends StatefulWidget {
  final Incidente incidente;

  const IncidenteCard({super.key, required this.incidente});

  @override
  State<StatefulWidget> createState() => _IncidenteCardState();

}

class _IncidenteCardState extends State<IncidenteCard> {

  late StatusIncidente status = widget.incidente.status;

  @override
  Widget build(BuildContext context) {
    final incidente = widget.incidente;
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
                  label: Text(
                    incidente.severidade.textoExibicao,
                    style: TextStyle(
                    color: corDaSeveridade(incidente.severidade),
                    fontWeight: FontWeight.bold
                    ),
                  ),
                  backgroundColor: corDaSeveridade(incidente.severidade).withValues(alpha: 0.14),
                  side: BorderSide(color: corDaSeveridade(incidente.severidade),),
                ),
                Text(incidente.abertoHa),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  iconeDaSeveridade(incidente.severidade),
                  color: corDaSeveridade(incidente.severidade),
                ),
                const SizedBox(width: 8),
                Text(
                  incidente.titulo,
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                    status.texto,
                    style: TextStyle(
                      color: corDoStatus(status),
                      fontWeight: FontWeight.bold
                      ),
                  ),
                  backgroundColor: Colors.grey.shade200,
                  side: BorderSide(color: corDoStatus(status))
                ),
                Text(incidente.responsavel ?? 'Sem responsável'),
              ],
            ),
            ElevatedButton(
              onPressed:() {
                setState(() {
                  status = status.proximo;
                });
              },
              child: Text("Avançar status")
            )
          ],
        ),
      ),
    );
  }
}
