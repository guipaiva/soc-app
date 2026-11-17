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

Future<ReputacaoIp> consultarReputacao(String ip) async {
  final url = Uri.parse('https://api.abuseipdb.com/api/v2/check?ipAddress=$ip');
  final resposta = await http.get(
    url,
    headers: {'Key': chaveAbuseIpdb, 'Accept': 'application/json'},
  );
  final corpo = jsonDecode(resposta.body);

  if (resposta.statusCode != 200) {
    throw corpo['errors'][0]['detail'] as String;
  }

  final dados = corpo['data'];
  return ReputacaoIp(
    score: dados['abuseConfidenceScore'] as int,
    pais: dados['countryCode'] as String?,
    provedor: dados['isp'] as String?,
    denuncias: dados['totalReports'] as int,
  );
}
