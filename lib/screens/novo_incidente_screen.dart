import 'package:flutter/material.dart';
import '../models/incidente.dart';

class NovoIncidenteScreen extends StatefulWidget {
  final String idNovo;

  const NovoIncidenteScreen({
    super.key,
    required this.idNovo,
  });

  @override
  State<NovoIncidenteScreen> createState() =>
      _NovoIncidenteScreenState();
}

class _NovoIncidenteScreenState extends State<NovoIncidenteScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _ipController = TextEditingController();

  String _tipoSelecionado = 'Outro';
  Severidade _severidadeSelecionada = Severidade.medio;

  final List<String> _tipos = [
    'Phishing',
    'Malware',
    'DDoS',
    'Acesso não autorizado',
    'Outro',
  ];

  final List<Severidade> _severidades = [
    Severidade.critico,
    Severidade.alto,
    Severidade.medio,
    Severidade.baixo,
  ];

  // Valida o título.
  String? validarTitulo(String? valor) {
    final titulo = (valor ?? '').trim();

    if (titulo.isEmpty) {
      return 'Este campo é obrigatório.';
    }

    if (titulo.length < 5) {
      return 'O título deve ter pelo menos 5 caracteres.';
    }

    return null;
  }

  // Valida a descrição.
  String? validarDescricao(String? valor) {
    final descricao = (valor ?? '').trim();

    if (descricao.isEmpty) {
      return 'Este campo é obrigatório.';
    }

    if (descricao.length < 20) {
      return 'A descrição deve ter pelo menos 20 caracteres.';
    }

    return null;
  }

  // Valida o endereço IPv4, caso seja informado.
  String? validarIp(String? valor) {
    final ip = (valor ?? '').trim();

    // O IP é opcional.
    if (ip.isEmpty) {
      return null;
    }

    final partes = ip.split('.');

    // IPv4 deve possuir exatamente quatro partes.
    if (partes.length != 4) {
      return 'Informe um endereço IPv4 válido.';
    }

    for (final parte in partes) {
      // Cada parte deve conter apenas números.
      if (parte.isEmpty || !RegExp(r'^\d+$').hasMatch(parte)) {
        return 'Informe um endereço IPv4 válido.';
      }

      final numero = int.tryParse(parte);

      // Cada número deve estar entre 0 e 255.
      if (numero == null || numero < 0 || numero > 255) {
        return 'Cada número do IP deve estar entre 0 e 255.';
      }
    }

    return null;
  }

  // Converte a severidade selecionada para um texto.
  String textoSeveridade(Severidade severidade) {
    switch (severidade) {
      case Severidade.critico:
        return 'Crítico';
      case Severidade.alto:
        return 'Alto';
      case Severidade.medio:
        return 'Médio';
      case Severidade.baixo:
        return 'Baixo';
    }
  }

  // Cria o incidente e devolve o objeto para a tela anterior.
  void criarIncidente() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ip = _ipController.text.trim();

    final incidente = Incidente(
      id: widget.idNovo,
      titulo: _tituloController.text.trim(),
      tipo: _tipoSelecionado,
      severidade: _severidadeSelecionada,
      status: StatusIncidente.aberto,
      abertoEm: DateTime.now(),
      descricao: _descricaoController.text.trim(),
      ipRelacionado: ip.isEmpty ? null : ip,
      // responsavel não informado = sem responsável.
    );

    Navigator.pop(context, incidente);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _ipController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo incidente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _tituloController,
              validator: validarTitulo,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Digite o título do incidente',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Tipo
            const Text(
              'Tipo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tipos.map((tipo) {
                return ChoiceChip(
                  label: Text(tipo),
                  selected: _tipoSelecionado == tipo,
                  onSelected: (selecionado) {
                    if (selecionado) {
                      setState(() {
                        _tipoSelecionado = tipo;
                      });
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Severidade
            const Text(
              'Severidade',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _severidades.map((severidade) {
                return ChoiceChip(
                  label: Text(textoSeveridade(severidade)),
                  selected: _severidadeSelecionada == severidade,
                  onSelected: (selecionado) {
                    if (selecionado) {
                      setState(() {
                        _severidadeSelecionada = severidade;
                      });
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Descrição
            TextFormField(
              controller: _descricaoController,
              validator: validarDescricao,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Descreva o incidente...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // IP relacionado
            TextFormField(
              controller: _ipController,
              validator: validarIp,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'IP relacionado (opcional)',
                hintText: 'Ex.: 187.44.12.90',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            // Criar incidente
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: criarIncidente,
                child: const Text('Criar incidente'),
              ),
            ),

            const SizedBox(height: 8),

            // Cancelar
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}