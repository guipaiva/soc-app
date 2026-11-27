import 'package:flutter/material.dart';
import '../services/auth_servico.dart';

String? validarEmail(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) {
    return 'Este campo é obrigatório.';
  }
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto)) {
    return 'E-mail inválido.';
  }
  return null;
}

String? validarSenhaDeLogin(String? valor) {
  if ((valor ?? '').isEmpty) {
    return 'Este campo é obrigatório.';
  }
  return null;
}

String? validarSenhaNova(String? valor) {
  final texto = valor ?? '';
  if (texto.isEmpty) {
    return 'Este campo é obrigatório.';
  }
  if (texto.length < 6) {
    return 'Mínimo de 6 caracteres.';
  }
  return null;
}

/// Campos de e-mail e senha com botão de envio, usado no login e no cadastro.
///
/// [aoEnviar] deve lançar [FalhaAutenticacaoException] quando falhar; a
/// mensagem aparece acima do botão. Enquanto a chamada está em andamento o
/// botão fica desabilitado e mostra um indicador de carregamento.
class FormularioAuth extends StatefulWidget {
  final String textoBotao;
  final bool novaConta;
  final Future<void> Function(String email, String senha) aoEnviar;
  final ValueChanged<bool>? aoMudarCarregamento;

  const FormularioAuth({
    super.key,
    required this.textoBotao,
    required this.aoEnviar,
    this.novaConta = false,
    this.aoMudarCarregamento,
  });

  @override
  State<FormularioAuth> createState() => _FormularioAuthState();
}

class _FormularioAuthState extends State<FormularioAuth> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _senhaFocus = FocusNode();
  bool carregando = false;
  bool ocultarSenha = true;
  String? erro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _senhaFocus.dispose();
    super.dispose();
  }

  Future<void> enviar() async {
    if (carregando) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      carregando = true;
      erro = null;
    });
    widget.aoMudarCarregamento?.call(true);

    String? falha;
    try {
      await widget.aoEnviar(_emailController.text, _senhaController.text);
    } on FalhaAutenticacaoException catch (e) {
      falha = e.mensagem;
    }

    // Em caso de sucesso a tela costuma ser trocada, então este widget já pode
    // ter saído da árvore.
    if (!mounted) {
      return;
    }
    setState(() {
      carregando = false;
      erro = falha;
    });
    widget.aoMudarCarregamento?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              enabled: !carregando,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: validarEmail,
              onFieldSubmitted: (_) {
                _senhaFocus.requestFocus();
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _senhaController,
              focusNode: _senhaFocus,
              enabled: !carregando,
              obscureText: ocultarSenha,
              textInputAction: TextInputAction.done,
              autofillHints: [
                widget.novaConta
                    ? AutofillHints.newPassword
                    : AutofillHints.password,
              ],
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock_outline),
                helperText: widget.novaConta ? 'Mínimo de 6 caracteres.' : null,
                suffixIcon: IconButton(
                  tooltip: ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
                  icon: Icon(
                    ocultarSenha ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      ocultarSenha = !ocultarSenha;
                    });
                  },
                ),
              ),
              validator: widget.novaConta
                  ? validarSenhaNova
                  : validarSenhaDeLogin,
              onFieldSubmitted: (_) {
                enviar();
              },
            ),
            if (erro != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.14),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        erro!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: carregando ? null : enviar,
              child: carregando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.textoBotao),
            ),
          ],
        ),
      ),
    );
  }
}
