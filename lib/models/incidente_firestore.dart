import 'package:cloud_firestore/cloud_firestore.dart';
import 'incidente.dart';

extension IncidenteFirestore on Incidente {
  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'tipo': tipo,
        'severidade': severidade.name,
        'status': status.name,
        'abertoEm': Timestamp.fromDate(abertoEm),
        'responsavel': responsavel,
        'descricao': descricao,
        'ipRelacionado': ipRelacionado,
      };
}

Incidente incidenteDeDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final d = doc.data() ?? {};
  return Incidente(
    id: doc.id,
    titulo: d['titulo'] as String? ?? '',
    tipo: d['tipo'] as String? ?? 'Outro',
    severidade: Severidade.values.firstWhere(
      (s) => s.name == d['severidade'],
      orElse: () => Severidade.baixo,
    ),
    status: StatusIncidente.values.firstWhere(
      (s) => s.name == d['status'],
      orElse: () => StatusIncidente.aberto,
    ),
    abertoEm: (d['abertoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    responsavel: d['responsavel'] as String?,
    descricao: d['descricao'] as String? ?? '',
    ipRelacionado: d['ipRelacionado'] as String?,
  );
}