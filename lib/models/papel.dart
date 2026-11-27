/// Papel do usuário, guardado no campo `papel` de `usuarios/<uid>`.
/// O nome do valor (analista, operador, administrador) é o texto gravado no
/// Firestore e usado nas regras.
enum Papel {
  analista('Analista'),
  operador('Operador'),
  administrador('Administrador');

  final String texto;
  const Papel(this.texto);

  bool get podeCriar => this == Papel.operador || this == Papel.administrador;

  bool get podeMudarStatus =>
      this == Papel.analista || this == Papel.administrador;

  bool get podeExcluir => this == Papel.administrador;
}

/// Converte o texto do Firestore em [Papel]; devolve null se for desconhecido.
Papel? papelDoTexto(Object? valor) {
  for (final papel in Papel.values) {
    if (papel.name == valor) {
      return papel;
    }
  }
  return null;
}
