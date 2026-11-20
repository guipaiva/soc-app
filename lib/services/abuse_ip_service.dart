import 'dart:convert';
import 'package:http/http.dart' as http;

const chaveAbuseIpdb  = String.fromEnvironment('ABUSEIPDB_KEY');

class ReputacaoIp {
  final int abuseConfidenceScore;
  final String? countryCode;
  final String? isp;
  final int totalReports;

  ReputacaoIp ({ 
    required this.abuseConfidenceScore,
    this.countryCode,
    this.isp,
    required this.totalReports,
  });

  factory ReputacaoIp.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ReputacaoIp(
      abuseConfidenceScore: data['abuseConfidenceScore'] ?? 0,
      countryCode: data['countryCode'],
      isp: data['isp'],
      totalReports: data['totalReports'] ?? 0,
    );
  }
}

Future<ReputacaoIp> consultarReputacaoIp(String ip) async {
  final url = Uri.parse('https://api.abuseipdb.com/api/v2/check?ipAddress=$ip');

  final resposta = await http.get(
    url,
    headers: {
      'Key': chaveAbuseIpdb,
      'Accept': 'application/json',
    },
  );

  final corpo = jsonDecode(resposta.body);

  if (resposta.statusCode == 200) {
    return ReputacaoIp.fromJson(corpo);
  } else {
    final motivo = (corpo['errors'] != null && corpo['errors'].isNotEmpty)
      ? corpo['errors'][0]['detail']
      : 'Falha na consulta (${resposta.statusCode})';
    throw Exception(motivo);
  }
}