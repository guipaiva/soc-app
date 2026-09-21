import 'package:flutter/material.dart';

import 'screens/incidentes_screen.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Central de Incidentes',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const IncidentesScreen(),
    ),
  );
}
