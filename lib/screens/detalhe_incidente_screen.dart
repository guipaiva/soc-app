import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../widgets/incidente_card.dart';

class DetalheIncidenteScreen extends StatefulWidget {
  final Incidente incidente;

  const DetalheIncidenteScreen({super.key, required this.incidente});

  @override
  State<DetalheIncidenteScreen> createState() => _DetalheIncidenteScreenState();
}

class _DetalheIncidenteScreenState extends State<DetalheIncidenteScreen> {
  late StatusIncidente statusMarcado = widget.incidente.status;

  Widget campo(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              rotulo,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidente = widget.incidente;

    return Scaffold(
      appBar: AppBar(title: Text('#${incidente.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ChipSeveridade(severidade: incidente.severidade),
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
          Text(
            'Descrição',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(incidente.descricao),
          const SizedBox(height: 16),
          Text(
            'Status',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: StatusIncidente.values
                .map(
                  (status) => ChoiceChip(
                    label: Text(status.texto),
                    selected: statusMarcado == status,
                    onSelected: (selecionado) {
                      setState(() {
                        statusMarcado = status;
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, statusMarcado);
            },
            child: const Text('Salvar atualização'),
          ),
        ],
      ),
    );
  }
}
