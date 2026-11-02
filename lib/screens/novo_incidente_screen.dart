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
    String? descricao;
    String? ipRelacionado;

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
        ],
      ),
    );
  }
}
