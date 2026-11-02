import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../widgets/incidente_card.dart';
import 'detalhe_incidente_screen.dart';
import 'novo_incidente_screen.dart';

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
        'Cinco tentativas de login inválidas na conta administrativa em '
        'menos de dois minutos, originadas de um IP fora da faixa corporativa.',
    ipRelacionado: '45.33.12.201',
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
        'Login VPN bem-sucedido às 03h12, fora da janela de acesso liberada '
        'para a credencial, a partir de um IP nunca visto antes para esse '
        'usuário.',
    ipRelacionado: '203.0.113.44',
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
        'Múltiplos e-mails com link fraudulento imitando o portal de RH foram '
        'reportados por três colaboradores do setor financeiro nas últimas '
        'duas horas.',
    ipRelacionado: '187.44.12.90',
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
        'O antivírus da estação FIN-07 bloqueou um executável anexado a um '
        'e-mail de fornecedor; a estação foi isolada da rede para análise.',
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
        'A API pública recebeu picos de requisições vindos de poucos IPs; o '
        'limite de requisições por IP foi reduzido e o tráfego normalizou.',
    ipRelacionado: '198.51.100.23',
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
        'O certificado da intranet expirou e os navegadores passaram a exibir '
        'alerta de conexão insegura; o certificado foi renovado.',
  ),
];

class ListaIncidentesScreen extends StatefulWidget {
  const ListaIncidentesScreen({super.key});

  @override
  State<ListaIncidentesScreen> createState() => _ListaIncidentesScreenState();
}

class _ListaIncidentesScreenState extends State<ListaIncidentesScreen> {
  StatusIncidente? filtro;

  String proximoId() {
    var maior = 0;
    for (final incidente in incidentes) {
      final numero = int.parse(incidente.id.substring(4));
      if (numero > maior) {
        maior = numero;
      }
    }
    return 'INC-${maior + 1}';
  }

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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final novo = await Navigator.push(
                    context,
                    MaterialPageRoute<Incidente>(
                      builder: (context) =>
                          NovoIncidenteScreen(id: proximoId()),
                    ),
                  );
                  if (novo != null) {
                    setState(() {
                      incidentes.insert(0, novo);
                    });
                  }
                },
                child: const Text('Novo incidente'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
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
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Em andamento'),
                  selected: filtro == StatusIncidente.emAndamento,
                  onSelected: (_) {
                    setState(() {
                      filtro = StatusIncidente.emAndamento;
                    });
                  },
                ),
                const SizedBox(width: 8),
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
                        final novoStatus = await Navigator.push(
                          context,
                          MaterialPageRoute<StatusIncidente>(
                            builder: (context) =>
                                DetalheIncidenteScreen(incidente: incidente),
                          ),
                        );
                        if (novoStatus != null) {
                          setState(() {
                            incidente.status = novoStatus;
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
