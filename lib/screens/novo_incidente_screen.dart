import 'package:flutter/material.dart';
import '../models/incidente.dart';

class NovoIncidenteScreen extends StatefulWidget {
  const NovoIncidenteScreen({super.key});

  @override
  State<NovoIncidenteScreen> createState() => _NovoIncidenteScreenState();
}

class _NovoIncidenteScreenState extends State<NovoIncidenteScreen> {
    final _formKey = GlobalKey<FormState>();
    TipoIncidente tipo = TipoIncidente.outro;
    Severidade severidade = Severidade.medio;
    final _descricaoController = TextEditingController();
    final _ipRelacionadoController = TextEditingController();
    final _tituloController = TextEditingController();

    @override
    void dispose() {
        _descricaoController.dispose();
        _ipRelacionadoController.dispose();
        _tituloController.dispose();
        super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Novo incidente')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
            Form(
            key: _formKey,
          child: Column(
            children: [
                TextField(
                    controller: _tituloController,
                    decoration: InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 12),
                const Text(
                    'Tipo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TipoIncidente.values.map((e) => ChoiceChip(
                    label: Text(e.texto),
                    selected: tipo == e,
                    onSelected: (_) {
                        setState(() {
                        tipo = e;
                        });
                    },
                    )).toList(),
                ),
                const SizedBox(height: 12),
                const Text(
                    'Severidade',
                    style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Severidade.values.map((e) => ChoiceChip(
                    label: Text(e.texto),
                    selected: severidade == e,
                    onSelected: (_) {
                        setState(() {
                        severidade = e;
                        });
                    },
                    )).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: _descricaoController,
                    decoration: InputDecoration(labelText: 'Descrição'),
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: _ipRelacionadoController,
                    decoration: InputDecoration(labelText: 'IP relacionado (opcional)'),
                ),
            ],
          )),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
                if (_formKey.currentState!.validate()) {
                    setState(() {
                        
                    });
                }
              Navigator.pop(context);
            },
            child: const Text('Criar incidente'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
                if (_formKey.currentState!.validate()) {
                    setState(() {
                        
                    });
                }
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
