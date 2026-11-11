import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/incidente.dart';
import '../widgets/incidente_card.dart';
import 'detalhe_incidente_screen.dart';
import 'novo_incidente_screen.dart';

final agora = DateTime.now();

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

Incidente incidenteDoFirestore(String id, Map<String, dynamic> dados) {
  final Timestamp abertoEm = dados['abertoEm'];
  return Incidente(
    id: id,
    titulo: dados['titulo'] as String,
    tipo: dados['tipo'] as String,
    severidade: Severidade.values.byName(dados['severidade'] as String),
    status: StatusIncidente.values.byName(dados['status'] as String),
    abertoEm: abertoEm.toDate(),
    responsavel: dados['responsavel'] as String?,
    descricao: dados['descricao'] as String,
    ipRelacionado: dados['ipRelacionado'] as String?,
  );
}

class ListaIncidentesScreen extends StatefulWidget {
  const ListaIncidentesScreen({super.key});

  @override
  State<ListaIncidentesScreen> createState() => _ListaIncidentesScreenState();
}

class _ListaIncidentesScreenState extends State<ListaIncidentesScreen> {
  StatusIncidente? filtro;

  final colecao = FirebaseFirestore.instance.collection('incidentes');
  late final Stream<QuerySnapshot<Map<String, dynamic>>> fluxo = colecao
      .orderBy('abertoEm', descending: true)
      .snapshots();

  Future<void> carregarExemplos() async {
    for (final exemplo in exemplos) {
      await colecao.doc(exemplo.id).set(exemplo.toMap());
    }
  }

  // O próximo número vem do maior id que já existe no banco, não de um
  // contador na memória do app.
  Future<String> proximoId() async {
    final resultado = await colecao.get();
    var maior = 1045;
    for (final doc in resultado.docs) {
      final numero = int.tryParse(doc.id.replaceFirst('INC-', ''));
      if (numero != null && numero > maior) {
        maior = numero;
      }
    }
    return 'INC-${maior + 1}';
  }

  Future<void> abrirNovoIncidente() async {
    final id = await proximoId();
    if (!mounted) return;
    final novo = await Navigator.push(
      context,
      MaterialPageRoute<Incidente>(
        builder: (context) => NovoIncidenteScreen(proximoId: id),
      ),
    );
    if (novo != null) {
      await colecao.doc(novo.id).set(novo.toMap());
    }
  }

  Future<void> abrirDetalhe(Incidente incidente) async {
    final novoStatus = await Navigator.push(
      context,
      MaterialPageRoute<StatusIncidente>(
        builder: (context) => DetalheIncidenteScreen(incidente: incidente),
      ),
    );
    if (novoStatus != null) {
      await colecao.doc(incidente.id).update({'status': novoStatus.name});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incidentes')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: fluxo,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar incidentes: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: carregarExemplos,
                child: const Text('Carregar exemplos'),
              ),
            );
          }

          final incidentes = docs
              .map((doc) => incidenteDoFirestore(doc.id, doc.data()))
              .toList();
          final visiveis = incidentes
              .where(
                (incidente) => filtro == null || incidente.status == filtro,
              )
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: abrirNovoIncidente,
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
                          onTap: () => abrirDetalhe(incidente),
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
