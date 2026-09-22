import 'package:flutter/material.dart';
import 'screens/incidentes_page.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Central de Incidentes',
      home: const IncidentesPage(),
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
  ));
}
