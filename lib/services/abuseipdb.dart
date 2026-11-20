import 'dart:convert';

import 'package:http/http.dart' as http;

const chaveAbuseIpdb = String.fromEnvironment('ABUSEIPDB_KEY');

class ReputacaoIp {
  final int score;
  final String? pais;
  final String? provedor;
  final int denuncias;

  ReputacaoIp({
    required this.score,
    required this.pais,
    required this.provedor,
    required this.denuncias,
  });
}

class FalhaNaConsulta implements Exception {
  final String motivo;
  FalhaNaConsulta(this.motivo);

  @override
  String toString() => motivo;
}

Future<ReputacaoIp> consultarReputacao(String ip) async {
  final url = Uri.https('api.abuseipdb.com', '/api/v2/check', {
    'ipAddress': ip,
  });
  final resposta = await http.get(
    url,
    headers: {'Key': chaveAbuseIpdb, 'Accept': 'application/json'},
  );
  final corpo = jsonDecode(resposta.body);

  if (resposta.statusCode != 200) {
    final List erros = corpo['errors'];
    throw FalhaNaConsulta(erros[0]['detail']);
  }

  final dados = corpo['data'];
  return ReputacaoIp(
    score: dados['abuseConfidenceScore'],
    pais: dados['countryCode'], // pode vir null (IP reservado)
    provedor: dados['isp'], // pode vir null
    denuncias: dados['totalReports'],
  );
}
