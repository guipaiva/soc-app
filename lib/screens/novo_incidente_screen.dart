import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../widgets/incidente_card.dart';

const List<String> tipos = [
  'Phishing',
  'Malware',
  'DDoS',
  'Acesso não autorizado',
  'Outro',
];

String? validarTitulo(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) {
    return 'Este campo é obrigatório.';
  }
  if (texto.length < 5) {
    return 'O título tem pelo menos 5 caracteres.';
  }
  return null;
}

String? validarDescricao(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) {
    return 'Este campo é obrigatório.';
  }
  if (texto.length < 20) {
    return 'A descrição tem pelo menos 20 caracteres.';
  }
  return null;
}

String? validarIp(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) {
    return null;
  }
  final partes = texto.split('.');
  if (partes.length != 4) {
    return 'O IP tem quatro números separados por ponto.';
  }
  for (final parte in partes) {
    if (!RegExp(r'^[0-9]+$').hasMatch(parte)) {
      return 'O IP tem quatro números separados por ponto.';
    }
    if (int.parse(parte) > 255) {
      return 'Cada número do IP vai de 0 a 255.';
    }
  }
  return null;
}

class NovoIncidenteScreen extends StatefulWidget {
  final String id;

  const NovoIncidenteScreen({super.key, required this.id});

  @override
  State<NovoIncidenteScreen> createState() => _NovoIncidenteScreenState();
}

class _NovoIncidenteScreenState extends State<NovoIncidenteScreen> {
  final formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final ipController = TextEditingController();
  String tipo = 'Outro';
  Severidade severidade = Severidade.medio;

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    ipController.dispose();
    super.dispose();
  }

  void criar() {
    if (!formKey.currentState!.validate()) {
      return;
    }
    final ip = ipController.text.trim();
    final incidente = Incidente(
      id: widget.id,
      titulo: tituloController.text.trim(),
      tipo: tipo,
      severidade: severidade,
      status: StatusIncidente.aberto,
      abertoEm: DateTime.now(),
      descricao: descricaoController.text.trim(),
      ipRelacionado: ip.isEmpty ? null : ip,
    );
    Navigator.pop(context, incidente);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo incidente')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: validarTitulo,
            ),
            const SizedBox(height: 16),
            const Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tipos
                  .map(
                    (opcao) => ChoiceChip(
                      label: Text(opcao),
                      selected: opcao == tipo,
                      onSelected: (_) {
                        setState(() {
                          tipo = opcao;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Severidade',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Severidade.values
                  .map(
                    (opcao) => ChoiceChip(
                      label: Text(textoDaSeveridade(opcao)),
                      selected: opcao == severidade,
                      onSelected: (_) {
                        setState(() {
                          severidade = opcao;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: null,
              validator: validarDescricao,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: ipController,
              decoration: const InputDecoration(
                labelText: 'IP relacionado (opcional)',
              ),
              validator: validarIp,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: criar,
              child: const Text('Criar incidente'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
