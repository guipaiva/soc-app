import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../services/incidentes_service.dart';
import '../widgets/incidente_card.dart';

class DetalheIncidenteScreen extends StatefulWidget {
  final Incidente incidente;

  const DetalheIncidenteScreen({super.key, required this.incidente});

  @override
  State<DetalheIncidenteScreen> createState() => _DetalheIncidenteScreenState();
}

class _DetalheIncidenteScreenState extends State<DetalheIncidenteScreen> {
  StatusIncidente? escolhido;
  bool _salvando = false;

  // Grava só o campo status do documento deste incidente.
  Future<void> salvar(StatusIncidente status) async {
    setState(() {
      _salvando = true;
    });

    try {
      await IncidentesService.atualizarStatus(widget.incidente.id, status);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  Widget campo(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(rotulo, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidente = widget.incidente;
    final status = escolhido ?? incidente.status;
    final corSeveridade = corDaSeveridade(incidente.severidade);

    return Scaffold(
      appBar: AppBar(title: Text('#${incidente.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Chip(
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
            ],
          ),
          const SizedBox(height: 8),
          Text(
            incidente.titulo,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          campo('Tipo', incidente.tipo),
          campo('Aberto', incidente.abertoHa),
          campo('Responsável', incidente.responsavel ?? 'Sem responsável'),
          campo('IP relacionado', incidente.ipRelacionado ?? '—'),
          const SizedBox(height: 16),
          const Text(
            'Descrição',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(incidente.descricao),
          const SizedBox(height: 16),
          const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: StatusIncidente.values
                .map(
                  (opcao) => ChoiceChip(
                    label: Text(opcao.texto),
                    selected: opcao == status,
                    onSelected: (_) {
                      setState(() {
                        escolhido = opcao;
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _salvando ? null : () => salvar(status),
            child: const Text('Salvar atualização'),
          ),
        ],
      ),
    );
  }
}
