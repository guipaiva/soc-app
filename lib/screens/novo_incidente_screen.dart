import 'package:flutter/material.dart';

import '../models/incidente.dart';
import '../widgets/incidente_card.dart';

const tipos = ['Phishing', 'Malware', 'DDoS', 'Acesso não autorizado', 'Outro'];

String? validarTitulo(String? valor) {
  final texto = (valor ?? '').trim();

  if (texto.isEmpty) {
    return 'Este campo é obrigatório.';
  }

  if (texto.length < 5) {
    return 'Mínimo de 5 caracteres.';
  }

  return null;
}

String? validarDescricao(String? valor) {
  final texto = (valor ?? '').trim();

  if (texto.isEmpty) {
    return 'Este campo é obrigatório.';
  }

  if (texto.length < 20) {
    return 'Mínimo de 20 caracteres.';
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
    return 'IPv4 inválido.';
  }

  for (final parte in partes) {
    final numero = int.tryParse(parte);

    if (numero == null || numero < 0 || numero > 255) {
      return 'IPv4 inválido.';
    }
  }

  return null;
}

class NovoIncidenteScreen extends StatefulWidget {
  final String proximoId;

  const NovoIncidenteScreen({super.key, required this.proximoId});

  @override
  State<NovoIncidenteScreen> createState() => _NovoIncidenteScreenState();
}

class _NovoIncidenteScreenState extends State<NovoIncidenteScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _ipController = TextEditingController();

  String tipo = 'Outro';
  Severidade severidade = Severidade.medio;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _ipController.dispose();

    super.dispose();
  }

  void criar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ip = _ipController.text.trim();

    final novo = Incidente(
      id: widget.proximoId,
      titulo: _tituloController.text.trim(),
      tipo: tipo,
      severidade: severidade,
      status: StatusIncidente.aberto,
      abertoEm: DateTime.now(),
      descricao: _descricaoController.text.trim(),
      ipRelacionado: ip.isEmpty ? null : ip,
    );

    Navigator.pop<Incidente>(context, novo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo incidente')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: validarTitulo,
            ),

            const SizedBox(height: 16),

            const Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 4),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tipos.map((opcao) {
                return ChoiceChip(
                  label: Text(opcao),
                  selected: opcao == tipo,
                  onSelected: (_) {
                    setState(() {
                      tipo = opcao;
                    });
                  },
                );
              }).toList(),
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
              children: Severidade.values.map((opcao) {
                return ChoiceChip(
                  label: Text(textoDaSeveridade(opcao)),
                  selected: opcao == severidade,
                  onSelected: (_) {
                    setState(() {
                      severidade = opcao;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 4,
              validator: validarDescricao,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _ipController,
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
