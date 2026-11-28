import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/lista_incidentes_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      title: 'Central de Incidentes',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthGate(),
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        return CarregadorPerfilScreen(key: ValueKey(user.uid), uid: user.uid);
      },
    );
  }
}

class CarregadorPerfilScreen extends StatefulWidget {
  final String uid;

  const CarregadorPerfilScreen({super.key, required this.uid});

  @override
  State<CarregadorPerfilScreen> createState() => _CarregadorPerfilScreenState();
}

class _CarregadorPerfilScreenState extends State<CarregadorPerfilScreen> {
  late final Future<DocumentSnapshot> _perfilFuture;

  @override
  void initState() {
    super.initState();
    _perfilFuture = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _perfilFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Erro ao carregar perfil.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text('Sair'),
                  ),
                ],
              ),
            ),
          );
        }

        final perfil = snapshot.data!;
        if (!perfil.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('Incidentes')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Conta sem papel. Peça acesso a um administrador.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      child: const Text('Sair'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final papel = perfil['papel'] as String;
        return ListaIncidentesScreen(papel: papel);
      },
    );
  }
}