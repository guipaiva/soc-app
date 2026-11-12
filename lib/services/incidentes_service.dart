import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incidente.dart';

class IncidentesService {
  static final _db = FirebaseFirestore.instance;
  static final _colecao = _db.collection('incidentes');
  static final _contador = _db.collection('contadores').doc('incidentes');

  // Coleção em tempo real, do mais novo para o mais antigo.
  static Stream<QuerySnapshot<Map<String, dynamic>>> get stream =>
      _colecao.orderBy('abertoEm', descending: true).snapshots();

  // Grava cada exemplo com o próprio id e inicia o contador de ids.
  static Future<void> carregarExemplos(List<Incidente> exemplos) async {
    final batch = _db.batch();
    var maior = 0;

    for (final e in exemplos) {
      batch.set(_colecao.doc(e.id), e.toMap());
      final n = int.tryParse(e.id.replaceFirst('INC-', '')) ?? 0;
      if (n > maior) maior = n;
    }

    batch.set(_contador, {'ultimo': maior});
    await batch.commit();
  }

  // Gera o próximo id e grava o incidente na mesma transação.
  static Future<String> criar({
    required String titulo,
    required String tipo,
    required Severidade severidade,
    required String descricao,
    String? ipRelacionado,
  }) {
    return _db.runTransaction<String>((tx) async {
      final contadorSnap = await tx.get(_contador);
      final ultimo = contadorSnap.data()?['ultimo'] as int?;

      if (ultimo == null) {
        throw StateError(
          'Contador não encontrado. Carregue os exemplos primeiro.',
        );
      }

      final id = 'INC-${ultimo + 1}';
      final ref = _colecao.doc(id);

      if ((await tx.get(ref)).exists) {
        throw StateError('O identificador $id já existe.');
      }

      final incidente = Incidente(
        id: id,
        titulo: titulo,
        tipo: tipo,
        severidade: severidade,
        status: StatusIncidente.aberto,
        abertoEm: DateTime.now(),
        descricao: descricao,
        ipRelacionado: ipRelacionado,
      );

      tx.set(_contador, {'ultimo': ultimo + 1});
      tx.set(ref, incidente.toMap());
      return id;
    });
  }

  // Troca só o campo status do documento.
  static Future<void> atualizarStatus(String id, StatusIncidente status) {
    return _colecao.doc(id).update({'status': status.name});
  }
}
