import 'dart:convert';

import 'package:http/http.dart' as http;

// Tem que ser const: String.fromEnvironment só lê o --dart-define em tempo de compilação.
const String chaveAbuseIpdb = String.fromEnvironment('ABUSEIPDB_KEY');

class AbuseIpdbResultado {
  final int abuseConfidenceScore;
  final String? countryCode;
  final String? isp;
  final int totalReports;

  const AbuseIpdbResultado({
    required this.abuseConfidenceScore,
    required this.countryCode,
    required this.isp,
    required this.totalReports,
  });

  factory AbuseIpdbResultado.fromJson(Map<String, dynamic> data) {
    return AbuseIpdbResultado(
      abuseConfidenceScore: (data['abuseConfidenceScore'] as num?)?.toInt() ?? 0,
      countryCode: data['countryCode'] as String?,
      isp: data['isp'] as String?,
      totalReports: (data['totalReports'] as num?)?.toInt() ?? 0,
    );
  }
}

class AbuseIpdbException implements Exception {
  final String mensagem;
  final int? statusCode;

  AbuseIpdbException(this.mensagem, {this.statusCode});

  @override
  String toString() => statusCode == null
      ? 'AbuseIpdbException: $mensagem'
      : 'AbuseIpdbException ($statusCode): $mensagem';
}

Future<AbuseIpdbResultado> consultarIp(String ip, {http.Client? client}) async {
  if (chaveAbuseIpdb.isEmpty) {
    throw AbuseIpdbException(
        'ABUSEIPDB_KEY não definida (use --dart-define=ABUSEIPDB_KEY=...)');
  }

  // Uri.https faz o encode do ip na query (importante pra IPv6 com ':').
  final url = Uri.https('api.abuseipdb.com', '/api/v2/check', {'ipAddress': ip});
  final c = client ?? http.Client();

  http.Response resposta;
  try {
    resposta = await c.get(url, headers: {
      'Key': chaveAbuseIpdb,
      'Accept': 'application/json',
    });
  } catch (e) {
    throw AbuseIpdbException('Falha de rede ao consultar a AbuseIPDB: $e');
  } finally {
    if (client == null) c.close();
  }

  Map<String, dynamic> corpo;
  try {
    corpo = jsonDecode(resposta.body) as Map<String, dynamic>;
  } catch (_) {
    throw AbuseIpdbException('Resposta inválida da AbuseIPDB',
        statusCode: resposta.statusCode);
  }

  final erros = corpo['errors'];
  if (erros is List && erros.isNotEmpty) {
    final detalhe = (erros.first as Map<String, dynamic>)['detail'] as String?;
    throw AbuseIpdbException(detalhe ?? 'Erro desconhecido',
        statusCode: resposta.statusCode);
  }

  final data = corpo['data'];
  if (resposta.statusCode != 200 || data is! Map<String, dynamic>) {
    throw AbuseIpdbException('Resposta inesperada da AbuseIPDB',
        statusCode: resposta.statusCode);
  }

  return AbuseIpdbResultado.fromJson(data);
}
