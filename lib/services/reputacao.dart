import 'dart:convert';
import 'package:http/http.dart' as http;

const chaveAbuseIpdb = String.fromEnvironment('ABUSEIPDB_KEY');

Future<Map<String, dynamic>> consultarReputacao(String ip) async {
  // 1. Montar a URL
  final url = Uri.parse(
    'https://api.abuseipdb.com/api/v2/check?ipAddress=$ip',
  );
  // 2. Fazer o GET com a chave e esperar a resposta
  final resposta = await http.get(
    url,
    headers: {'Key': chaveAbuseIpdb, 'Accept': 'application/json'},
  );
  // 3. Converter o corpo em Map
  final corpo = jsonDecode(resposta.body);
  // 4. Conferir o status
  if (resposta.statusCode != 200) {
    return {'erro': corpo['errors'][0]['detail']};
  }
  return corpo['data'];
}
