import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../widgets/incidente_card.dart';
import 'detalhe_incidente_screen.dart';

final agora = DateTime.now();
final List<Incidente> incidentes = [
  Incidente(
    id: 'INC-1045',
    titulo: 'Login falho repetido — conta admin',
    tipo: 'Acesso não autorizado',
    severidade: Severidade.critico,
    status: StatusIncidente.aberto,
    abertoEm: agora.subtract(const Duration(minutes: 15)),
    descricao:
        'Mais de 40 tentativas de login falhas na conta admin em 10 minutos, '
        'vindas de um único endereço externo.',
    ipRelacionado: '203.0.113.42',
  ),
  Incidente(
    id: 'INC-1044',
    titulo: 'Acesso fora do horário — VPN corporativa',
    tipo: 'Acesso não autorizado',
    severidade: Severidade.critico,
    status: StatusIncidente.aberto,
    abertoEm: agora.subtract(const Duration(minutes: 40)),
    responsavel: 'Ana Souza',
    descricao:
        'Conexão à VPN corporativa às 03h12 com credenciais de um usuário '
        'que estava de férias.',
    ipRelacionado: '198.51.100.17',
  ),
  Incidente(
    id: 'INC-1042',
    titulo: 'Tentativa de phishing — portal de RH',
    tipo: 'Phishing',
    severidade: Severidade.alto,
    status: StatusIncidente.emAndamento,
    abertoEm: agora.subtract(const Duration(hours: 3)),
    responsavel: 'Ana Souza',
    descricao:
        'E-mail falso imitando o portal de RH pedia que os funcionários '
        'confirmassem a senha em um link externo.',
    ipRelacionado: '192.0.2.88',
  ),
  Incidente(
    id: 'INC-1039',
    titulo: 'Malware detectado — estação FIN-07',
    tipo: 'Malware',
    severidade: Severidade.alto,
    status: StatusIncidente.emAndamento,
    abertoEm: agora.subtract(const Duration(days: 1, hours: 2)),
    responsavel: 'Carlos Lima',
    descricao:
        'O antivírus isolou um executável suspeito na estação FIN-07 do '
        'financeiro. A máquina foi desconectada da rede.',
  ),
  Incidente(
    id: 'INC-1031',
    titulo: 'Picos de tráfego — API pública',
    tipo: 'DDoS',
    severidade: Severidade.medio,
    status: StatusIncidente.resolvido,
    abertoEm: agora.subtract(const Duration(days: 2, hours: 5)),
    responsavel: 'Ana Souza',
    descricao:
        'Picos de requisições na API pública derrubaram a latência por '
        'cerca de 20 minutos. O tráfego foi bloqueado no firewall.',
    ipRelacionado: '203.0.113.200',
  ),
  Incidente(
    id: 'INC-1027',
    titulo: 'Certificado TLS expirado — intranet',
    tipo: 'Outro',
    severidade: Severidade.baixo,
    status: StatusIncidente.resolvido,
    abertoEm: agora.subtract(const Duration(days: 4)),
    responsavel: 'Carlos Lima',
    descricao:
        'O certificado TLS da intranet expirou e os navegadores exibiram '
        'aviso de segurança. Um novo certificado foi emitido.',
  ),
];

class ListaIncidentesScreen extends StatefulWidget {
  const ListaIncidentesScreen({super.key});

  @override
  State<ListaIncidentesScreen> createState() => _ListaIncidentesScreenState();
}

class _ListaIncidentesScreenState extends State<ListaIncidentesScreen> {
  StatusIncidente? filtro;

  @override
  Widget build(BuildContext context) {
    final visiveis = incidentes
        .where((incidente) => filtro == null || incidente.status == filtro)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Incidentes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: filtro == null,
                  onSelected: (_) {
                    setState(() {
                      filtro = null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Em andamento'),
                  selected: filtro == StatusIncidente.emAndamento,
                  onSelected: (_) {
                    setState(() {
                      filtro = StatusIncidente.emAndamento;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Resolvidos'),
                  selected: filtro == StatusIncidente.resolvido,
                  onSelected: (_) {
                    setState(() {
                      filtro = StatusIncidente.resolvido;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: visiveis
                  .map(
                    (incidente) => GestureDetector(
                      onTap: () async {
                        final resposta = await Navigator.push(
                          context,
                          MaterialPageRoute<StatusIncidente>(
                            builder: (context) =>
                                DetalheIncidenteScreen(incidente: incidente),
                          ),
                        );
                        if (resposta != null) {
                          setState(() {
                            incidente.status = resposta;
                          });
                        }
                      },
                      child: IncidenteCard(incidente: incidente),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}