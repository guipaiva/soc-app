enum TipoIncidente {
  phishing,
  malware,
  acessoNaoAutorizado,
  ddos,
  outro,
}

enum Severidade{
  critico,
  alto,
  medio,
  baixo
}

enum StatusIncidente{
  aberto,
  emAndamento,
  resolvido
}

class Incidente {
  final String identificador;
  final String titulo;
  final TipoIncidente tipo;
  final Severidade severidade;
  final StatusIncidente status;
  final DateTime abertoEm;
  final String? responsavel;

  Incidente({
    required this.identificador,
    required this.titulo,
    required this.tipo,
    required this.severidade,
    required this.status,
    required this.abertoEm,
    required this.responsavel,
  });


  String get tempoDecorrido {
  final diff = DateTime.now().difference(abertoEm);
  if (diff.inDays > 0) {
    return '${diff.inDays} dias atrás';
  } else if (diff.inHours > 0) {
    return '${diff.inHours} horas atrás';
  } else if (diff.inMinutes > 0) {
    return '${diff.inMinutes} minutos atrás';
  } else {
    return 'agora mesmo';
  }
}
}

