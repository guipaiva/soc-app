import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../widgets/incidente_card.dart';

const List<String> tiposDeIncidente = [
  'Phishing',
  'Malware',
  'DDoS',
  'Acesso não autorizado',
  'Outro',
];

const String mensagemObrigatorio = 'Este campo é obrigatório';

String? validarTitulo(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) {
    return mensagemObrigatorio;
  }
  if (texto.length < 5) {
    return 'O título deve ter pelo menos 5 caracteres';
  }
  return null;
}

String? validarDescricao(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) {
    return mensagemObrigatorio;
  }
  if (texto.length < 20) {
    return 'A descrição deve ter pelo menos 20 caracteres';
  }
  return null;
}

String? validarIp(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) {
    return null; // campo opcional: vazio é válido
  }

  final partes = texto.split('.');
  if (partes.length != 4) {
    return 'Informe um IPv4 válido (ex.: 192.168.0.1)';
  }

  final somenteDigitos = RegExp(r'^\d{1,3}$');
  for (final parte in partes) {
    if (!somenteDigitos.hasMatch(parte) || int.parse(parte) > 255) {
      return 'Informe um IPv4 válido (ex.: 192.168.0.1)';
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

  String _tipo = 'Outro';
  Severidade _severidade = Severidade.medio;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  void _criarIncidente() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ip = _ipController.text.trim();

    final novoIncidente = Incidente(
      id: widget.proximoId,
      titulo: _tituloController.text.trim(),
      tipo: _tipo,
      severidade: _severidade,
      status: StatusIncidente.aberto,
      abertoEm: DateTime.now(),
      descricao: _descricaoController.text.trim(),
      ipRelacionado: ip.isEmpty ? null : ip,
    );

    Navigator.pop(context, novoIncidente);
  }

  void _cancelar() {
    Navigator.pop(context);
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
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: validarTitulo,
            ),
            const SizedBox(height: 16),

            const Text('Tipo'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tiposDeIncidente
                  .map(
                    (tipo) => ChoiceChip(
                      label: Text(tipo),
                      selected: _tipo == tipo,
                      onSelected: (_) {
                        setState(() {
                          _tipo = tipo;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            const Text('Severidade'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Severidade.values
                  .map(
                    (severidade) => ChoiceChip(
                      label: Text(textoDaSeveridade(severidade)),
                      selected: _severidade == severidade,
                      selectedColor:
                          corDaSeveridade(severidade).withValues(alpha: 0.2),
                      onSelected: (_) {
                        setState(() {
                          _severidade = severidade;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: validarDescricao,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP relacionado (opcional)',
                border: OutlineInputBorder(),
              ),
              validator: validarIp,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelar,
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _criarIncidente,
                    child: const Text('Criar incidente'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}