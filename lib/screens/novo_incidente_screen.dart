import 'package:flutter/material.dart';
import '../models/incidente.dart';

String? validarTitulo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
        return 'Este campo é obrigatório.';
    }
    if (valor.trim().length < 5) {
        return 'O título tem pelo menos 5 letras';
    }
    return null;
}

String? validarDescricao(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
        return 'Este campo é obrigatório.';
    }
    if (valor.trim().length < 20) {
        return 'A descrição tem pelo menos 20 letras';
    }
    return null;
}

String? validarIpRelacionado(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
        return null;
    }

    final ipv4Regex = RegExp(
        r'^((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$',
    );

    if (!ipv4Regex.hasMatch(valor.trim())) {
        return 'O IP está no padrão errado, quatro números de 0 a 255 separados por ponto. Válidos: 187.44.12.90, 10.0.0.1';
    }
    return null;
}

class NovoIncidenteScreen extends StatefulWidget {
    final int numUltimoIncidente;

  const NovoIncidenteScreen({super.key, required this.numUltimoIncidente});

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
                TextFormField(
                    controller: _tituloController,
                    decoration: InputDecoration(labelText: 'Título'),
                    validator: validarTitulo,
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
                TextFormField(
                    controller: _descricaoController,
                    decoration: InputDecoration(labelText: 'Descrição'),
                    validator: validarDescricao,
                ),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _ipRelacionadoController,
                    decoration: InputDecoration(labelText: 'IP relacionado (opcional)'),
                    validator: validarIpRelacionado,
                ),
            ],
          )),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
                if (_formKey.currentState!.validate()) {
                    Incidente novoIncidente = Incidente(
                        id: 'INC-'+widget.numUltimoIncidente.toString(),
                        titulo: _tituloController.text,
                        tipo: tipo,
                        severidade: severidade,
                        status: StatusIncidente.aberto,
                        abertoEm: DateTime.now(),
                        descricao: _descricaoController.text,
                        ipRelacionado: _ipRelacionadoController.text == ''? null: _ipRelacionadoController.text,
                    );
                    Navigator.pop(context, novoIncidente);
                }
            },
            child: const Text('Criar incidente'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
