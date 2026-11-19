import 'dart:convert';

import 'package:http/http.dart' as http;

// A chave vem do chaves.json via --dart-define-from-file e nunca é escrita aqui.
const chaveAbuseIpdb = String.fromEnvironment('ABUSEIPDB_KEY');

class ReputacaoIp {
  final String ip;
  final int score;
  final String? pais;
  final String? provedor;
  final int? denuncias;

  const ReputacaoIp({
    required this.ip,
    required this.score,
    this.pais,
    this.provedor,
    this.denuncias,
  });

  factory ReputacaoIp.fromJson(Map<String, dynamic> data) {
    return ReputacaoIp(
      ip: data['ipAddress'] as String,
      score: (data['abuseConfidenceScore'] as num).toInt(),
      pais: data['countryCode'] as String?,
      provedor: data['isp'] as String?,
      denuncias: (data['totalReports'] as num?)?.toInt(),
    );
  }
}

/// Não foi possível falar com a AbuseIPDB (sem internet ou bloqueio do navegador).
class SemConexaoException implements Exception {
  const SemConexaoException();
}

/// A API respondeu com status diferente de 200; [motivo] vem de errors[0].detail.
class FalhaConsultaException implements Exception {
  final String motivo;
  const FalhaConsultaException(this.motivo);

  @override
  String toString() => motivo;
}

Future<ReputacaoIp> consultarReputacaoIp(String ip) async {
  final url = Uri.https('api.abuseipdb.com', '/api/v2/check', {
    'ipAddress': ip,
  });

  final http.Response resposta;
  try {
    resposta = await http.get(
      url,
      headers: {'Key': chaveAbuseIpdb, 'Accept': 'application/json'},
    );
  } on http.ClientException {
    throw const SemConexaoException();
  }

  Map<String, dynamic>? corpo;
  try {
    corpo = jsonDecode(resposta.body) as Map<String, dynamic>;
  } catch (_) {
    corpo = null;
  }

  if (resposta.statusCode == 200 && corpo != null) {
    return ReputacaoIp.fromJson(corpo['data'] as Map<String, dynamic>);
  }

  String motivo = 'Erro ${resposta.statusCode}';
  final erros = corpo?['errors'];
  if (erros is List && erros.isNotEmpty) {
    final detalhe = (erros.first as Map)['detail'];
    if (detalhe is String && detalhe.isNotEmpty) motivo = detalhe;
  }
  throw FalhaConsultaException(motivo);
}