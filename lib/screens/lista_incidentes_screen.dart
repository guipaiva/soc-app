import 'package:flutter/material.dart';

import '../models/incidente.dart';
import '../widgets/incidente_card.dart';
import 'detalhe_incidente_screen.dart';

final DateTime agora = DateTime.now();

final List<Incidente> incidentes = [
  Incidente(
    id: 'INC-1045',
    titulo: 'Login falho repetido — conta admin',
    tipo: 'Acesso não autorizado',
    severidade: Severidade.critico,
    status: StatusIncidente.aberto,
    abertoEm: agora.subtract(const Duration(minutes: 15)),
    descricao: 'Múltiplas tentativas de login falharam para a conta admin. Possível ataque de força bruta.',
    ipRelacionado: '192.168.12.5',
  ),
  Incidente(
    id: 'INC-1044',
    titulo: 'Acesso fora do horário — VPN corporativa',
    tipo: 'Acesso não autorizado',
    severidade: Severidade.critico,
    status: StatusIncidente.aberto,
    abertoEm: agora.subtract(const Duration(minutes: 40)),
    responsavel: 'Ana Souza',
    descricao: 'Usuário acessou a VPN corporativa fora do horário permitido. Possível violação de política de segurança.',
    ipRelacionado: '192.168.1.55',
  ),
  Incidente(
    id: 'INC-1042',
    titulo: 'Tentativa de phishing — portal de RH',
    tipo: 'Phishing',
    severidade: Severidade.alto,
    status: StatusIncidente.emAndamento,
    abertoEm: agora.subtract(const Duration(hours: 3)),
    responsavel: 'Ana Souza',
    descricao: 'Usuário recebeu e clicou em um link suspeito no portal de RH. Investigação em andamento.',
    ipRelacionado: '192.168.1.55',
  ),
  Incidente(
    id: 'INC-1039',
    titulo: 'Malware detectado — estação FIN-07',
    tipo: 'Malware',
    severidade: Severidade.alto,
    status: StatusIncidente.emAndamento,
    abertoEm: agora.subtract(const Duration(days: 1, hours: 2)),
    responsavel: 'Carlos Lima',
    descricao: 'Malware detectado na estação FIN-07. Investigação em andamento.',
    ipRelacionado: '192.168.1.55',
  ),
  Incidente(
    id: 'INC-1031',
    titulo: 'Picos de tráfego — API pública',
    tipo: 'DDoS',
    severidade: Severidade.medio,
    status: StatusIncidente.resolvido,
    abertoEm: agora.subtract(const Duration(days: 2, hours: 5)),
    responsavel: 'Ana Souza',
    descricao: 'Picos de tráfego incomuns detectados na API pública. Medidas mitigadoras aplicadas.',
  ),
  Incidente(
    id: 'INC-1027',
    titulo: 'Certificado TLS expirado — intranet',
    tipo: 'Outro',
    severidade: Severidade.baixo,
    status: StatusIncidente.resolvido,
    abertoEm: agora.subtract(const Duration(days: 4)),
    responsavel: 'Carlos Lima',
    descricao: 'Certificado TLS expirado na intranet. Manutenção programada.',
  ),
];

class ListaIncidentesScreen extends StatefulWidget {
  const ListaIncidentesScreen({super.key});

  @override
  State<ListaIncidentesScreen> createState() => _ListaIncidentesScreenState();
}

class _ListaIncidentesScreenState extends State<ListaIncidentesScreen> {
  FiltroIncidentes _filtro = FiltroIncidentes.todos;

  List<Incidente> get _incidentesVisiveis => incidentes.where((incidente) {
        switch (_filtro) {
          case FiltroIncidentes.todos:
            return true;
          case FiltroIncidentes.emAndamento:
            return incidente.status == StatusIncidente.emAndamento;
          case FiltroIncidentes.resolvidos:
            return incidente.status == StatusIncidente.resolvido;
        }
      }).toList();

  Future<void> _abrirDetalhe(Incidente incidente) async {
    final novoStatus = await Navigator.push<StatusIncidente>(
      context,
      MaterialPageRoute(
        builder: (_) => DetalheIncidenteScreen(incidente: incidente),
      ),
    );

    if (!mounted || novoStatus == null) return;
    setState(() => incidente.status = novoStatus);
  }

  @override
  Widget build(BuildContext context) {
    final visiveis = _incidentesVisiveis;

    return Scaffold(
      appBar: AppBar(title: const Text('Incidentes')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: FiltroIncidentes.values.map((filtro) {
                final texto = switch (filtro) {
                  FiltroIncidentes.todos => 'Todos',
                  FiltroIncidentes.emAndamento => 'Em andamento',
                  FiltroIncidentes.resolvidos => 'Resolvidos',
                };

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(texto),
                    selected: _filtro == filtro,
                    onSelected: (_) => setState(() => _filtro = filtro),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: visiveis.isEmpty
                  ? const [Center(child: Text('Nenhum incidente neste filtro.'))]
                  : visiveis
                      .map(
                        (incidente) => IncidenteCard(
                          incidente: incidente,
                          onTap: () => _abrirDetalhe(incidente),
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
