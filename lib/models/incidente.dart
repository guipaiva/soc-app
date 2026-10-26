import 'package:flutter/material.dart';

enum Severidade { critico, alto, medio, baixo }

enum StatusIncidente {
  aberto('Aberto'),
  emAndamento('Em andamento'),
  resolvido('Resolvido');

  final String texto;
  const StatusIncidente(this.texto);

}

enum FiltroIncidentes { todos, emAndamento, resolvidos }

class Incidente {
  final String id;
  final String titulo;
  final String tipo;
  final Severidade severidade;
  StatusIncidente status;
  final DateTime abertoEm;
  final String descricao;
  final String? responsavel;
  final String? ipRelacionado;

  Incidente({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.severidade,
    required this.status,
    required this.abertoEm,
    required this.descricao,
    this.responsavel,
    this.ipRelacionado,
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
