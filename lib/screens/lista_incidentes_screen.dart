import 'package:cloud_firestore/cloud_firestore.dart';
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

final referenciaColecaoIncidentes =
    FirebaseFirestore.instance.collection('incidentes');

int calcularProximoNumeroDoIncidente(List<Incidente> listaDeTodosOsIncidentes) {
  int maiorNumeroEncontrado = 1045;

  for (int posicao = 0; posicao < listaDeTodosOsIncidentes.length; posicao++) {
    String identificadorAtual = listaDeTodosOsIncidentes[posicao].id;

    String parteNumericaDoIdentificador = identificadorAtual.substring(4);
    int? numeroDoIdentificador = int.tryParse(parteNumericaDoIdentificador);

    if (numeroDoIdentificador != null) {
      if (numeroDoIdentificador > maiorNumeroEncontrado) {
        maiorNumeroEncontrado = numeroDoIdentificador;
      }
    }
  }

  return maiorNumeroEncontrado + 1;
}

class ListaIncidentesScreen extends StatefulWidget {
  const ListaIncidentesScreen({super.key});

  @override
  State<ListaIncidentesScreen> createState() => _ListaIncidentesScreenState();
}

class _ListaIncidentesScreenState extends State<ListaIncidentesScreen> {
  StatusIncidente? filtro;

  final streamDosIncidentes = referenciaColecaoIncidentes
      .orderBy('abertoEm', descending: true)
      .snapshots();

  Future<void> gravarIncidentesDeExemplo() async {
    for (int posicao = 0; posicao < incidentes.length; posicao++) {
      Incidente incidenteDeExemplo = incidentes[posicao];
      await referenciaColecaoIncidentes
          .doc(incidenteDeExemplo.id)
          .set(incidenteDeExemplo.toMap());
    }
  }

  Future<void> abrirNovoIncidente(String proximoId) async {
    final novo = await Navigator.push(
      context,
      MaterialPageRoute<Incidente>(
        builder: (context) =>
            NovoIncidenteScreen(proximoId: proximoId),
      ),
    );

    if (novo != null) {
      await referenciaColecaoIncidentes
          .doc(novo.id)
          .set(novo.toMap());
    }
  }

  Future<void> abrirTelaDetalhe(Incidente incidenteSelecionado) async {
    final novoStatus = await Navigator.push(
      context,
      MaterialPageRoute<StatusIncidente>(
        builder: (context) =>
            DetalheIncidenteScreen(incidente: incidenteSelecionado),
      ),
    );

    if (novoStatus != null) {
      await referenciaColecaoIncidentes.doc(incidenteSelecionado.id).update({
        'status': novoStatus.name,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incidentes')),
      body: StreamBuilder(
        stream: streamDosIncidentes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os incidentes'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Incidente> listaDeTodosOsIncidentes = [];
          for (var documentoDoBanco in snapshot.data!.docs) {
            Incidente incidenteConvertido = incidenteDoFirestore(
              documentoDoBanco.id,
              documentoDoBanco.data(),
            );
            listaDeTodosOsIncidentes.add(incidenteConvertido);
          }

          if (listaDeTodosOsIncidentes.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: gravarIncidentesDeExemplo,
                child: const Text('Carregar exemplos'),
              ),
            );
          }

          List<Incidente> visiveis = [];
          for (int posicao = 0;
              posicao < listaDeTodosOsIncidentes.length;
              posicao++) {
            Incidente incidenteAtual = listaDeTodosOsIncidentes[posicao];
            bool deveAparecerNaTela = filtro == null
                ? true
                : incidenteAtual.status == filtro;

            if (deveAparecerNaTela) {
              visiveis.add(incidenteAtual);
            }
          }

          int numeroDoProximoIncidente =
              calcularProximoNumeroDoIncidente(listaDeTodosOsIncidentes);
          String proximoId = 'INC-$numeroDoProximoIncidente';

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      abrirNovoIncidente(proximoId);
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
                            abrirTelaDetalhe(incidente);
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