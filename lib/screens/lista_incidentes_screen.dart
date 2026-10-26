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
        'Cinco tentativas de login sem sucesso na conta admin em menos de 2 minutos, todas vindas do mesmo endereço externo.',
    ipRelacionado: '203.0.113.45',
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
        'Conexão à VPN corporativa às 03h12 com credenciais de um colaborador que estava de férias.',
    ipRelacionado: '198.51.100.23',
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
        'E-mail imitando o portal de RH pedia que os colaboradores confirmassem login e senha num link externo.',
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
        'O antivírus da estação FIN-07 colocou em quarentena um executável baixado de um anexo de e-mail.',
    ipRelacionado: '10.0.4.17',
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
        'A API pública recebeu um volume de requisições muito acima do normal por cerca de 20 minutos, deixando respostas lentas.',
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
        'O certificado TLS da intranet expirou e os navegadores passaram a exibir alerta de conexão não segura.',
  ),
];

class ListaIncidentesScreen extends StatefulWidget {
  const ListaIncidentesScreen({super.key});

  @override
  State<ListaIncidentesScreen> createState() => _ListaIncidentesScreenState();
}

class _ListaIncidentesScreenState extends State<ListaIncidentesScreen> {
  // null significa "Todos"
  StatusIncidente? filtro;

  Future<void> abrirDetalhe(Incidente incidente) async {
    final novoStatus = await Navigator.push<StatusIncidente>(
      context,
      MaterialPageRoute(
        builder: (context) => DetalheIncidenteScreen(incidente: incidente),
      ),
    );

    if (novoStatus != null) {
      setState(() {
        incidente.status = novoStatus;
      });
    }
  }

  Widget chipFiltro(String texto, StatusIncidente? status) {
    return ChoiceChip(
      label: Text(texto),
      selected: filtro == status,
      onSelected: (selecionado) {
        setState(() {
          filtro = status;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = incidentes
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
                chipFiltro('Todos', null),
                chipFiltro('Em andamento', StatusIncidente.emAndamento),
                chipFiltro('Resolvidos', StatusIncidente.resolvido),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: filtrados
                  .map(
                    (incidente) => IncidenteCard(
                      incidente: incidente,
                      onTap: () => abrirDetalhe(incidente),
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
