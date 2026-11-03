import 'package:flutter/material.dart';

import '../models/incidente.dart';

String? validarTitulo(String? valor) {
  if (valor == null || valor.trim() == '') {
    return 'Este campo é obrigatório.';
  }
  if (valor.trim().length < 5) {
    return 'O título tem pelo menos 5 caracteres.';
  }
  return null;
}

String? validarDescricao(String? valor) {
  if (valor == null || valor.trim() == '') {
    return 'Este campo é obrigatório.';
  }
  if (valor.trim().length < 20) {
    return 'A descrição tem pelo menos 20 caracteres.';
  }
  return null;
}

String? validarIp(String? valor) {
  if (valor == null || valor.trim() == '') {
    return null;
  }
  List<String> partes = valor.trim().split('.');
  if (partes.length != 4) {
    return 'O IP tem quatro números separados por ponto.';
  }
  for (String parte in partes) {
    int? numero = int.tryParse(parte);
    if (numero == null) {
      return 'O IP só pode ter números.';
    }
    if (numero < 0 || numero > 255) {
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

  void criarIncidente() {
    if (formKey.currentState!.validate()) {
      String? ip;
      if (ipController.text.trim() != '') {
        ip = ipController.text.trim();
      }

      Incidente novo = Incidente(
        id: widget.id,
        titulo: tituloController.text.trim(),
        tipo: tipo,
        severidade: severidade,
        status: StatusIncidente.aberto,
        abertoEm: DateTime.now(),
        descricao: descricaoController.text.trim(),
        ipRelacionado: ip,
      );

      Navigator.pop(context, novo);
    }
  }

  Widget chipTipo(String nome) {
    return ChoiceChip(
      label: Text(nome),
      selected: tipo == nome,
      onSelected: (_) {
        setState(() {
          tipo = nome;
        });
      },
    );
  }

  Widget chipSeveridade(String nome, Severidade valor) {
    return ChoiceChip(
      label: Text(nome),
      selected: severidade == valor,
      onSelected: (_) {
        setState(() {
          severidade = valor;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo incidente')),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: validarTitulo,
              ),
              const SizedBox(height: 16),
              const Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  chipTipo('Phishing'),
                  chipTipo('Malware'),
                  chipTipo('DDoS'),
                  chipTipo('Acesso não autorizado'),
                  chipTipo('Outro'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Severidade',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  chipSeveridade('Crítico', Severidade.critico),
                  chipSeveridade('Alto', Severidade.alto),
                  chipSeveridade('Médio', Severidade.medio),
                  chipSeveridade('Baixo', Severidade.baixo),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 4,
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: criarIncidente,
                  child: const Text('Criar incidente'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
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
      ),
    );
  }
}
