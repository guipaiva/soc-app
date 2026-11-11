import 'package:cloud_firestore/cloud_firestore.dart';

enum Severidade { critico, alto, medio, baixo }

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
  final String tipo;
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

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'tipo': tipo,
      'severidade': severidade.name,
      'status': status.name,
      'abertoEm': abertoEm,
      'responsavel': responsavel,
      'descricao': descricao,
      'ipRelacionado': ipRelacionado,
    };
  }

  Incidente incidenteDoFirestore(String id, Map<String, dynamic> dados) {
    final Timestamp abertoEm = dados['abertoEm'];
    return Incidente(
      id: id,
      titulo: dados['titulo'],
      tipo: dados['tipo'],
      severidade: Severidade.values.byName(dados['severidade']),
      status: StatusIncidente.values.byName(dados['status']),
      abertoEm: abertoEm.toDate(),
      responsavel: dados['responsavel'],
      descricao: dados['descricao'],
      ipRelacionado: dados['ipRelacionado'],
    );
  }
}
