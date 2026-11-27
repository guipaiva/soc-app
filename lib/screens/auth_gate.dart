import 'package:flutter/material.dart';
import '../services/auth_servico.dart';
import 'login_screen.dart';
import 'perfil_gate.dart';

/// Decide a tela inicial: perfil (e lista de incidentes) se há usuário logado,
/// login se não.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: usuarioLogado(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          final usuario = snapshot.data!;
          // A chave faz o perfil ser lido de novo se entrar outra conta.
          return PerfilGate(key: ValueKey(usuario.uid), uid: usuario.uid);
        }
        return const LoginScreen();
      },
    );
  }
}
