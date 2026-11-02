enum Severidade {
  critico('Crítico'),
  alto('Alto'),
  medio('Médio'),
  baixo('Baixo');

  final String texto;
  const Severidade(this.texto);
}

enum TipoIncidente {
  phishing('Phishing'),
  malware('Malware'),
  ddos('DDoS'),
  acessoNaoAutorizado('Acesso não autorizado'),
  outro('Outro');

  final String texto;
  const TipoIncidente(this.texto);
}

enum StatusIncidente {
  aberto('Aberto'),
  emAndamento('Em andamento'),
  resolvido('Resolvido');

  final String texto;
  const StatusIncidente(this.texto);

  StatusIncidente get proximo {
    switch (this) {
      case StatusIncidente.aberto:
        return StatusIncidente.emAndamento;
      case StatusIncidente.emAndamento:
        return StatusIncidente.resolvido;
      case StatusIncidente.resolvido:
        return StatusIncidente.aberto;
    }
  }
}

class Incidente {
  final String id;
  final String titulo;
  final TipoIncidente tipo;
  final Severidade severidade;
  StatusIncidente status;
  final DateTime abertoEm;
  final String? responsavel;
  final String descricao;
  final String? ipRelacionado;

  Incidente({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.severidade,
    required this.status,
    required this.abertoEm,
    this.responsavel,
    required this.descricao,
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
