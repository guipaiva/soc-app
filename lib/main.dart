import 'package:flutter/material.dart';

import 'package:central_incidentes/screens/incidentes_screen.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Central de Incidentes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const IncidentesScreen(),
    ),
  );
}
