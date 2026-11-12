import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../services/incidentes_service.dart';
import '../widgets/incidente_card.dart';
import 'detalhe_incidente_screen.dart';
import 'novo_incidente_screen.dart';

final agora = DateTime.now();

// Incidentes de exemplo: só são gravados no banco pelo botão
// "Carregar exemplos" quando a coleção está vazia.
final List<Incidente> exemplos = [
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
  bool carregandoExemplos = false;

  // Criado uma vez, para não reassinar o stream a cada rebuild.
  final _stream = IncidentesService.stream;

  Future<void> carregarExemplos() async {
    setState(() {
      carregandoExemplos = true;
    });

    try {
      await IncidentesService.carregarExemplos(exemplos);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar exemplos: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregandoExemplos = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incidentes')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar incidentes:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final todos = snapshot.data!.docs
              .map((doc) => incidenteDoFirestore(doc.id, doc.data()))
              .toList();

          // Coleção vazia: só o botão para carregar os exemplos.
          if (todos.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: carregandoExemplos ? null : carregarExemplos,
                child: const Text('Carregar exemplos'),
              ),
            );
          }

          final visiveis = todos
              .where((incidente) => filtro == null || incidente.status == filtro)
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const NovoIncidenteScreen(),
                        ),
                      );
                    },
                    child: const Text('Novo incidente'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => DetalheIncidenteScreen(
                                  incidente: incidente,
                                ),
                              ),
                            );
                          },
                          child: IncidenteCard(incidente: incidente),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
