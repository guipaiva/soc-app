import 'package:flutter/material.dart';
import '../main.dart';


IconData iconePorSeveridade(Severidade severidade) {
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

String textoSeveridade(Severidade severidade) { 
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

  Color corSeveridade(Severidade severidade) { 
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
  String textoStatus(StatusIncidente status) { 
    switch (status) {
      case StatusIncidente.aberto:
        return 'Aberto';
      case StatusIncidente.emAndamento:
        return 'Em andamento';
      case StatusIncidente.resolvido:
        return 'Resolvido';
    }
  }

Color corStatus(StatusIncidente status) { 
  switch (status) {
    case StatusIncidente.aberto:
      return Colors.red;
    case StatusIncidente.emAndamento:
      return Colors.orange;
    case StatusIncidente.resolvido:
      return Colors.green;
  }
}

String textoTipo(TipoIncidente tipo) {
  switch (tipo) {
    case TipoIncidente.phishing:
      return 'Phishing';
    case TipoIncidente.malware:
      return 'Malware';
    case TipoIncidente.acessoNaoAutorizado:
      return 'Acesso não autorizado';
    case TipoIncidente.ddos:
      return 'DDoS';
    case TipoIncidente.outro:
      return 'Outro';
  }
}


class IncidenteCard extends StatelessWidget {
  final Incidente incidente;
  const IncidenteCard({super.key, required this.incidente});

  @override
  Widget build(BuildContext context) {
    final corSev = corSeveridade(incidente.severidade);
    final corSt = corStatus(incidente.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // linha 1: chip de severidade + tempo decorrido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(textoSeveridade(incidente.severidade)),
                  backgroundColor: corSev.withValues(alpha: 0.2),
                  side: BorderSide(color: corSev),
                ),
                Text(incidente.tempoDecorrido),
              ],
            ),
            const SizedBox(height: 8),

            // linha 2: ícone da severidade + título
            Row(
              children: [
                Icon(iconePorSeveridade(incidente.severidade), color: corSev),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    incidente.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // linha 3: #id · tipo, em cinza
            Text(
              '#${incidente.identificador} · ${textoTipo(incidente.tipo)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),

            // linha 4: chip de status + responsável
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    textoStatus(incidente.status),
                    style: TextStyle(color: corSt),
                  ),
                  backgroundColor: Colors.grey[200],
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