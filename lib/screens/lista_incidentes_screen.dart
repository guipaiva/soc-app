import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../models/incidente_firestore.dart';
import '../widgets/incidente_card.dart';
import 'detalhe_incidente_screen.dart';
import 'novo_incidente_screen.dart';

final agora = DateTime.now();

/// Apenas dados de exemplo: não é mais o que a tela mostra.
final List<Incidente> incidentesExemplo = [
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

/// Maior número de id entre os exemplos (INC-1045).
const int _ultimoNumeroExemplo = 1045;

class ListaIncidentesScreen extends StatefulWidget {
  const ListaIncidentesScreen({super.key});

  @override
  State<ListaIncidentesScreen> createState() => _ListaIncidentesScreenState();
}

class _ListaIncidentesScreenState extends State<ListaIncidentesScreen> {
  final _db = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _colecao =
      _db.collection('incidentes');
  // Guarda o último número já usado, para o id nunca se repetir.
  late final DocumentReference<Map<String, dynamic>> _contador =
      _db.collection('contadores').doc('incidentes');

  late Stream<QuerySnapshot<Map<String, dynamic>>> _stream = _criarStream();
  StatusIncidente? filtro;
  bool _carregandoExemplos = false;

  Stream<QuerySnapshot<Map<String, dynamic>>> _criarStream() =>
      _colecao.orderBy('abertoEm', descending: true).snapshots();

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<int> _ultimoNumero() async {
    final snap = await _contador.get();
    return (snap.data()?['ultimo'] as num?)?.toInt() ?? _ultimoNumeroExemplo;
  }

  Future<void> _carregarExemplos() async {
    setState(() => _carregandoExemplos = true);
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(_contador);
        final atual =
            (snap.data()?['ultimo'] as num?)?.toInt() ?? _ultimoNumeroExemplo;
        for (final inc in incidentesExemplo) {
          tx.set(_colecao.doc(inc.id), inc.toMap());
        }
        tx.set(_contador, {'ultimo': max(atual, _ultimoNumeroExemplo)});
      });
    } catch (e) {
      _mostrarMensagem('Não foi possível carregar os exemplos: $e');
    } finally {
      if (mounted) setState(() => _carregandoExemplos = false);
    }
  }

  Future<void> _abrirNovoIncidente() async {
    final int proximo;
    try {
      proximo = (await _ultimoNumero()) + 1;
    } catch (e) {
      _mostrarMensagem('Não foi possível obter o próximo id: $e');
      return;
    }
    if (!mounted) return;

    final novo = await Navigator.push(
      context,
      MaterialPageRoute<Incidente>(
        builder: (context) => NovoIncidenteScreen(proximoId: 'INC-$proximo'),
      ),
    );
    if (novo == null) return;

    final numero = int.tryParse(novo.id.split('-').last) ?? proximo;
    try {
      await _db.runTransaction((tx) async {
        final ref = _colecao.doc(novo.id);
        // Nunca sobrescreve um incidente existente.
        if ((await tx.get(ref)).exists) {
          throw StateError('O id ${novo.id} já existe.');
        }
        final snap = await tx.get(_contador);
        final atual =
            (snap.data()?['ultimo'] as num?)?.toInt() ?? _ultimoNumeroExemplo;
        tx.set(ref, novo.toMap());
        tx.set(_contador, {'ultimo': max(atual, numero)});
      });
    } catch (e) {
      _mostrarMensagem('Não foi possível criar o incidente: $e');
    }
  }

  Future<void> _abrirDetalhe(Incidente incidente) async {
    final novoStatus = await Navigator.push(
      context,
      MaterialPageRoute<StatusIncidente>(
        builder: (context) => DetalheIncidenteScreen(incidente: incidente),
      ),
    );
    if (novoStatus == null) return;
    try {
      // Troca só o campo `status` do documento.
      await _colecao.doc(incidente.id).update({'status': novoStatus.name});
    } catch (e) {
      _mostrarMensagem('Não foi possível salvar a atualização: $e');
    }
  }

  Widget _chip(String rotulo, StatusIncidente? valor) {
    return ChoiceChip(
      label: Text(rotulo),
      selected: filtro == valor,
      onSelected: (_) => setState(() => filtro = valor),
    );
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Erro ao carregar os incidentes.'),
                    const SizedBox(height: 4),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _stream = _criarStream()),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final todos = snapshot.data!.docs.map(incidenteDeDoc).toList();

          if (todos.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: _carregandoExemplos ? null : _carregarExemplos,
                child: _carregandoExemplos
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Carregar exemplos'),
              ),
            );
          }

          final visiveis = todos
              .where((i) => filtro == null || i.status == filtro)
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: _abrirNovoIncidente,
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
                    _chip('Todos', null),
                    _chip('Em andamento', StatusIncidente.emAndamento),
                    _chip('Resolvidos', StatusIncidente.resolvido),
                  ],
                ),
              ),
              Expanded(
                child: visiveis.isEmpty
                    ? const Center(
                        child: Text('Nenhum incidente neste filtro.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: visiveis.length,
                        itemBuilder: (context, index) {
                          final incidente = visiveis[index];
                          return GestureDetector(
                            onTap: () => _abrirDetalhe(incidente),
                            child: IncidenteCard(incidente: incidente),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}