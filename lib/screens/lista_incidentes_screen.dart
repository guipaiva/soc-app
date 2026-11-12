
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incidente.dart';
import '../widgets/incidente_card.dart';
import 'detalhe_incidente_screen.dart';
import 'novo_incidente_screen.dart';

Future<String> gerarProximoId() async {
  final db = FirebaseFirestore.instance;
  final contadorRef = db.collection('controle').doc('incidentes');

  final consultaIncidentes = await db.collection('incidentes').get();

  var maiorNumero = 1045;

  for (final documento in consultaIncidentes.docs) {
    final resultado = RegExp(r'^INC-(\d+)$').firstMatch(documento.id);

    if (resultado != null) {
      final numero = int.parse(resultado.group(1)!);

      if (numero > maiorNumero) {
        maiorNumero = numero;
      }
    }
  }

  return db.runTransaction<String>((transaction) async {
    final contadorSnapshot = await transaction.get(contadorRef);

    final ultimoNumeroSalvo =
        contadorSnapshot.data()?['ultimoNumero'] as int? ?? 1045;

    final base = ultimoNumeroSalvo > maiorNumero
        ? ultimoNumeroSalvo
        : maiorNumero;

    final proximoNumero = base + 1;

    transaction.set(contadorRef, {
      'ultimoNumero': proximoNumero,
    });

    return 'INC-${proximoNumero.toString().padLeft(4, '0')}';
  });
}

List<Incidente> _criarIncidentesExemplo() {
  final agora = DateTime.now();

  return [
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
}

class ListaIncidentesScreen extends StatefulWidget {
  const ListaIncidentesScreen({super.key});

  @override
  State<ListaIncidentesScreen> createState() =>
      _ListaIncidentesScreenState();
}

class _ListaIncidentesScreenState extends State<ListaIncidentesScreen> {
  StatusIncidente? filtro;

  bool carregandoExemplos = false;

  Future<void> abrirNovoIncidente() async {
    try {
      final proximoId = await gerarProximoId();

      if (!mounted) return;

      final novo = await Navigator.push<Incidente>(
        context,
        MaterialPageRoute<Incidente>(
          builder: (context) =>
              NovoIncidenteScreen(proximoId: proximoId),
        ),
      );

      if (novo == null) return;

      await FirebaseFirestore.instance
          .collection('incidentes')
          .doc(novo.id)
          .set(novo.toMap());
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar incidente: $erro'),
        ),
      );
    }
  }

  Future<void> abrirDetalhe(Incidente incidente) async {
    try {
      final novoStatus = await Navigator.push<StatusIncidente>(
        context,
        MaterialPageRoute<StatusIncidente>(
          builder: (context) =>
              DetalheIncidenteScreen(incidente: incidente),
        ),
      );

      if (novoStatus == null) return;

      await FirebaseFirestore.instance
          .collection('incidentes')
          .doc(incidente.id)
          .update({
        'status': novoStatus.name,
      });
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar incidente: $erro'),
        ),
      );
    }
  }

  Future<void> carregarExemplos() async {
    if (carregandoExemplos) return;

    setState(() {
      carregandoExemplos = true;
    });

    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();
      final referencia = db.collection('incidentes');

      for (final incidente in _criarIncidentesExemplo()) {
        batch.set(
          referencia.doc(incidente.id),
          incidente.toMap(),
        );
      }

      await batch.commit();
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar exemplos: $erro'),
        ),
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
      appBar: AppBar(
        title: const Text('Incidentes'),
      ),
      body: Column(
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
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('incidentes')
                  .orderBy('abertoEm', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar incidentes: ${snapshot.error}',
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final dados = snapshot.data;

                if (dados == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final documentos = dados.docs;

                if (documentos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Nenhum incidente encontrado.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: carregandoExemplos
                                ? null
                                : carregarExemplos,
                            child: carregandoExemplos
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Carregar exemplos'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final List<Incidente> todosIncidentes =
                    documentos.map<Incidente>((documento) {
                  return incidenteDoFirestore(
                    documento.id,
                    documento.data(),
                  );
                }).toList();

                final List<Incidente> visiveis =
                    todosIncidentes.where((Incidente incidente) {
                  return filtro == null || incidente.status == filtro;
                }).toList();

                if (visiveis.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum incidente encontrado para este filtro.',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: visiveis.length,
                  itemBuilder: (context, index) {
                    final incidente = visiveis[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => abrirDetalhe(incidente),
                        child: IncidenteCard(
                          incidente: incidente,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
