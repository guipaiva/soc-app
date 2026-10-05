import 'package:flutter/material.dart';
import '../models/incidente.dart';

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

String textoDoStatus(StatusIncidente status) {
  switch (status) {
    case StatusIncidente.aberto:
      return 'Aberto';
    case StatusIncidente.emAndamento:
      return 'Em andamento';
    case StatusIncidente.resolvido:
      return 'Resolvido';
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
  StatusIncidente status = StatusIncidente.aberto;

  @override
  void initState() {
    super.initState();

    status = widget.incidente.status;
  }

  @override
  Widget build(BuildContext context) {
  final corSeveridade = corDaSeveridade(widget.incidente.severidade);
  final corStatus = corDoStatus(status);

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
                    textoDaSeveridade(widget.incidente.severidade),
                    style: TextStyle(
                      color: corSeveridade,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: corSeveridade.withValues(alpha: 0.14),
                  side: BorderSide(color: corSeveridade),
                ),
                Text(
                  widget.incidente.abertoHa,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(iconeDaSeveridade(widget.incidente.severidade), color: corSeveridade),
                const SizedBox(width: 8),
                Text(
                  widget.incidente.titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '#${widget.incidente.id} · ${widget.incidente.tipo}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    textoDoStatus(status),
                    style: TextStyle(
                      color: corStatus,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.grey.shade200,
                ),
                Text(widget.incidente.responsavel ?? 'Sem responsável'),
              ],
            ),
              ElevatedButton(
              onPressed: (){
                setState(() {
                  status = status.proximo;
                });
              }, 
              child: Text("Avançar status"),
            ),
          ],
        ),
      ),
    );
  }
}
