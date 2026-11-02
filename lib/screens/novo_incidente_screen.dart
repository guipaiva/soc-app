import 'package:flutter/material.dart';
import '../models/incidente.dart';

class NovoIncidenteScreen extends StatefulWidget {
  const NovoIncidenteScreen({super.key});

  @override
  State<NovoIncidenteScreen> createState() => _NovoIncidenteScreenState();
}

class _NovoIncidenteScreenState extends State<NovoIncidenteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _ipController = TextEditingController();
  
  Severidade severidade = Severidade.medio;
  String tipo = 'Outro';

  static const tipos = ['Acesso não autorizado', 'Phishing', 'Malware', 'DDoS', 'Outro'];

  String? _validarIp(String? valor) {
  final ip = valor?.trim() ?? '';

  if (ip.isEmpty) return null;

  final partes = ip.split('.');
  if (partes.length != 4) {
    return 'O IP deve ter 4 números separados por ponto (ex: 192.168.0.1).';
  }

  for (final parte in partes) {
    if (!RegExp(r'^\d{1,3}$').hasMatch(parte)) {
      return 'Use apenas números entre os pontos.';
    }
    if (int.parse(parte) > 255) {
      return 'Cada número do IP vai de 0 a 255.';
    }
  }

  return null;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final novo = Incidente(
        id: 'INC-${1045 + 1}',
        titulo: _tituloController.text,
        tipo: tipo,
        severidade: severidade,
        status: StatusIncidente.aberto,
        abertoEm: DateTime.now(),
        descricao: _descricaoController.text,
        ipRelacionado: _ipController.text.trim().isEmpty ? null : _ipController.text.trim(),
      );
      Navigator.pop(context, novo);
    }
  }

  void _cancelar() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Novo Incidente"),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                validator: (String? t) {
                  if (t == null || t.trim().isEmpty) {
                  return 'Informe o título';
                  }
                  if (t.trim().length < 5) {
                  return 'O título tem pelo menos 5 caracteres';
                  }
                  return null;
                  },
                decoration: InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 16),
              const Text('Tipo'),
              Row(
                children: tipos.map((t) {
                  return ChoiceChip(
                    label: Text(t),
                    selected: tipo == t,
                    onSelected: (_) {setState(() => tipo = t);},
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Severidade'),
              Row(
                children: Severidade.values.map((sev) {
                  return ChoiceChip(
                    label: Text(sev.name),
                    selected: severidade == sev,
                    onSelected: (_) {setState(() => severidade = sev);},
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                validator: (String? d) {
                  if (d == null || d.trim().isEmpty) {
                    return 'Informe a descrição';
                  }
                  if (d.trim().length < 20) {
                  return 'A descrição tem pelo menos 20 caracteres';
                  }
                  return null;
                  },

                decoration: InputDecoration(labelText: 'Descrição'),  
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ipController,
                validator: _validarIp,
                decoration: InputDecoration(labelText: 'IP relacionado (opcional)'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                child: ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
              ),
              const SizedBox(height: 8),
              SizedBox(child: ElevatedButton(onPressed: _cancelar, child: const Text('Cancelar')),)
            ]
          )
        )
      )
    );
  }
}