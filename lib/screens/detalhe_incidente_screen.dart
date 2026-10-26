import 'package:flutter/material.dart';

import '../models/incidente.dart';

class CampoDetalhe extends StatelessWidget {
  const CampoDetalhe({super.key, required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rotulo, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(valor),
          ],
        ),
      );
}

class DetalheIncidenteScreen extends StatefulWidget {
  const DetalheIncidenteScreen({super.key, required this.incidente});

  final Incidente incidente;

  @override
  State<DetalheIncidenteScreen> createState() => _DetalheIncidenteScreenState();
}

class _DetalheIncidenteScreenState extends State<DetalheIncidenteScreen> {
  late StatusIncidente _statusSelecionado = widget.incidente.status;

  void _salvar() => Navigator.pop(context, _statusSelecionado);

  @override
  Widget build(BuildContext context) {
    final incidente = widget.incidente;
    final corSeveridade = corDaSeveridade(incidente.severidade);

    return Scaffold(
      appBar: AppBar(title: Text('#${incidente.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text(
                textoDaSeveridade(incidente.severidade),
                style: TextStyle(
                  color: corSeveridade,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: corSeveridade.withValues(alpha: 0.14),
              side: BorderSide(color: corSeveridade),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            incidente.titulo,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          CampoDetalhe(rotulo: 'Tipo', valor: incidente.tipo),
          CampoDetalhe(rotulo: 'Aberto', valor: incidente.abertoHa),
          CampoDetalhe(
            rotulo: 'Responsável',
            valor: incidente.responsavel ?? 'Sem responsável',
          ),
          CampoDetalhe(
            rotulo: 'IP relacionado',
            valor: incidente.ipRelacionado ?? '—',
          ),
          CampoDetalhe(rotulo: 'Descrição', valor: incidente.descricao),
          Text('Status', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: StatusIncidente.values.map((status) {
              return ChoiceChip(
                label: Text(status.texto),
                selected: _statusSelecionado == status,
                onSelected: (_) => setState(() => _statusSelecionado = status),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _salvar,
            child: const Text('Salvar atualização'),
          ),
        ],
      ),
    );
  }
}
