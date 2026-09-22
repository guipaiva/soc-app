import 'package:flutter/material.dart';
import 'screens/lista_incidentes_screen.dart';

void main() {
  runApp(const SocApp());
}

class SocApp extends StatelessWidget {
  const SocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Central de Incidentes',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const ListaIncidentesScreen(),
    );
  }
}