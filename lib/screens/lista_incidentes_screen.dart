import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/incidente.dart';
import '../widgets/incidente_card.dart';
import 'detalhe_incidente_screen.dart';
import 'novo_incidente_screen.dart';

Future<String> gerarProximoId() async {
  final db = FirebaseFirestore.instance;
  final contadorRef = db.collection('controle').doc('incidentes');

  final consulta = await db.collection('incidentes').get();

  var maiorNumero = 1045;

  for (final documento in consulta.docs) {
    final resultado = RegExp(r'^INC-(\d+)$').firstMatch(documento.id);

    if (resultado != null) {
      final numero = int.parse(resultado.group(1)!);

      if (numero > maiorNumero) {
        maiorNumero = numero;
      }
    }
  }

  return db.runTransaction<String>((transaction) async {
    final snapshot = await transaction.get(contadorRef);

    final ultimoNumeroSalvo =
        snapshot.data()?['ultimoNumero'] as int? ?? 1045;

    final base =
        ultimoNumeroSalvo > maiorNumero ? ultimoNumeroSalvo : maiorNumero;

    final proximoNumero = base + 1;

    transaction.set(contadorRef, {
      'ultimoNumero': proximoNumero,
    });

    return 'INC-${proximoNumero.toString().padLeft(4, '0')}';
  });
}

List<Incidente> _criarIncidentesExemplo() {
  return [
    Incidente(
      id: 'INC-1045',
      titulo: 'Login falho repetido',
      tipo: 'Acesso não autorizado',
      severidade: Severidade.critico,
      status: StatusIncidente.aberto,
      abertoEm: DateTime.now().subtract(const Duration(hours: 1)),
      responsavel: 'Ana Souza',
      descricao: 'Múltiplas tentativas de login falhas na conta admin.',
      ipRelacionado: '203.0.113.14',
    ),
    Incidente(
      id: 'INC-1044',
      titulo: 'Acesso fora do horário',
      tipo: 'Acesso não autorizado',
      severidade: Severidade.critico,
      status: StatusIncidente.aberto,
      abertoEm: DateTime.now().subtract(const Duration(hours: 3)),
      responsavel: 'Carlos Lima',
      descricao: 'Acesso à VPN corporativa fora do horário permitido.',
      ipRelacionado: '198.51.100.22',
    ),
    Incidente(
      id: 'INC-1042',
      titulo: 'Tentativa de phishing',
      tipo: 'Phishing',
      severidade: Severidade.alto,
      status: StatusIncidente.emAndamento,
      abertoEm: DateTime.now().subtract(const Duration(hours: 5)),
      responsavel: 'Ana Souza',
      descricao: 'E-mail suspeito simulando o portal de RH.',
      ipRelacionado: '203.0.113.45',
    ),
    Incidente(
      id: 'INC-1039',
      titulo: 'Malware detectado',
      tipo: 'Malware',
      severidade: Severidade.alto,
      status: StatusIncidente.emAndamento,
      abertoEm: DateTime.now().subtract(const Duration(hours: 8)),
      responsavel: 'Carlos Lima',
      descricao: 'Malware identificado na estação FIN-07.',
      ipRelacionado: '192.0.2.10',
    ),
    Incidente(
      id: 'INC-1031',
      titulo: 'Picos de tráfego',
      tipo: 'DDoS',
      severidade: Severidade.medio,
      status: StatusIncidente.resolvido,
      abertoEm: DateTime.now().subtract(const Duration(days: 1)),
      responsavel: 'Ana Souza',
      descricao: 'Picos anormais de tráfego na API pública.',
      ipRelacionado: '192.0.2.55',
    ),
    Incidente(
      id: 'INC-1027',
      titulo: 'Certificado TLS expirado',
      tipo: 'Outro',
      severidade: Severidade.baixo,
      status: StatusIncidente.resolvido,
      abertoEm: DateTime.now().subtract(const Duration(days: 2)),
      responsavel: null,
      descricao: 'Certificado TLS expirado na intranet.',
      ipRelacionado: null,
    ),
  ];
}

enum FiltroIncidentes {
  todos,
  emAndamento,
  resolvidos,
}

class ListaIncidentesScreen extends StatefulWidget {
  const ListaIncidentesScreen({super.key});

  @override
  State<ListaIncidentesScreen> createState() =>
      _ListaIncidentesScreenState();
}

class _ListaIncidentesScreenState extends State<ListaIncidentesScreen> {
  FiltroIncidentes filtro = FiltroIncidentes.todos;

  bool carregandoExemplos = false;

  late Future<DocumentSnapshot<Map<String, dynamic>>> perfilFuture;

  @override
  void initState() {
    super.initState();

    final usuario = FirebaseAuth.instance.currentUser;

    perfilFuture = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuario!.uid)
        .get();
  }

  Future<void> sair() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> carregarExemplos() async {
    setState(() {
      carregandoExemplos = true;
    });

    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      final exemplos = _criarIncidentesExemplo();

      for (final incidente in exemplos) {
        final ref = db.collection('incidentes').doc(incidente.id);

        batch.set(ref, incidente.toMap());
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exemplos carregados com sucesso!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar exemplos: $e'),
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

  Future<void> abrirNovoIncidente() async {
    try {
      final proximoId = await gerarProximoId();

      if (!mounted) return;

      final novo = await Navigator.push<Incidente>(
        context,
        MaterialPageRoute(
          builder: (_) => NovoIncidenteScreen(
            proximoId: proximoId,
          ),
        ),
      );

      if (novo == null) return;

      await FirebaseFirestore.instance
          .collection('incidentes')
          .doc(novo.id)
          .set(novo.toMap());
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar incidente: $e'),
        ),
      );
    }
  }

  Future<void> abrirDetalhe(
    Incidente incidente,
    String papel,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalheIncidenteScreen(
          incidente: incidente,
          papel: papel,
        ),
      ),
    );
  }

  Widget telaSemPapel() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOC App'),
        actions: [
          IconButton(
            onPressed: sair,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Conta sem papel. Peça acesso a um administrador.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  String nomePapel(String papel) {
    switch (papel) {
      case 'analista':
        return 'Analista';
      case 'operador':
        return 'Operador';
      case 'admin':
        return 'Administrador';
      default:
        return papel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: perfilFuture,
      builder: (context, perfilSnapshot) {
        if (perfilSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (perfilSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Erro ao carregar perfil: ${perfilSnapshot.error}'),
            ),
          );
        }

        final perfil = perfilSnapshot.data!;

        if (!perfil.exists) {
          return telaSemPapel();
        }

        final papel = perfil.data()?['papel'] as String?;

        if (papel == null ||
            !['analista', 'operador', 'admin'].contains(papel)) {
          return telaSemPapel();
        }

        final podeCriar = papel == 'operador' || papel == 'admin';
        final podeAlterarStatus = papel == 'analista' || papel == 'admin';

        return Scaffold(
          appBar: AppBar(
            title: Text('Incidentes — ${nomePapel(papel)}'),
            actions: [
              IconButton(
                onPressed: sair,
                icon: const Icon(Icons.logout),
                tooltip: 'Sair',
              ),
            ],
          ),
          body: Column(
            children: [
              if (podeCriar)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: abrirNovoIncidente,
                          icon: const Icon(Icons.add),
                          label: const Text('Novo incidente'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              carregandoExemplos ? null : carregarExemplos,
                          icon: const Icon(Icons.download),
                          label: Text(
                            carregandoExemplos
                                ? 'Carregando...'
                                : 'Carregar exemplos',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: filtro == FiltroIncidentes.todos,
                      onSelected: (_) {
                        setState(() {
                          filtro = FiltroIncidentes.todos;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Em andamento'),
                      selected: filtro == FiltroIncidentes.emAndamento,
                      onSelected: (_) {
                        setState(() {
                          filtro = FiltroIncidentes.emAndamento;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Resolvidos'),
                      selected: filtro == FiltroIncidentes.resolvidos,
                      onSelected: (_) {
                        setState(() {
                          filtro = FiltroIncidentes.resolvidos;
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
                        child: Text('Erro ao carregar incidentes: ${snapshot.error}'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final documentos = snapshot.data?.docs ?? [];

                    final incidentes = documentos
                        .map(
                          (documento) => incidenteDoFirestore(
                            documento.id,
                            documento.data(),
                          ),
                        )
                        .toList();

                    final visiveis = incidentes.where((incidente) {
                      switch (filtro) {
                        case FiltroIncidentes.todos:
                          return true;
                        case FiltroIncidentes.emAndamento:
                          return incidente.status ==
                              StatusIncidente.emAndamento;
                        case FiltroIncidentes.resolvidos:
                          return incidente.status ==
                              StatusIncidente.resolvido;
                      }
                    }).toList();

                    if (incidentes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Nenhum incidente cadastrado.'),
                            const SizedBox(height: 16),
                            if (podeCriar)
                              ElevatedButton(
                                onPressed: carregandoExemplos
                                    ? null
                                    : carregarExemplos,
                                child: const Text('Carregar exemplos'),
                              ),
                          ],
                        ),
                      );
                    }

                    if (visiveis.isEmpty) {
                      return const Center(
                        child: Text('Nenhum incidente neste filtro.'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: visiveis.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final incidente = visiveis[index];

                        return GestureDetector(
                          onTap: () => abrirDetalhe(
                            incidente,
                            papel,
                          ),
                          child: IncidenteCard(
                            incidente: incidente,
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
      },
    );
  }
}