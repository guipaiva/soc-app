import 'package:flutter/material.dart';
import '../widgets/incidente_card.dart';
import '../models/incidente.dart';

final agora = DateTime.now();

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key, required this.incidentes});

  final List<Incidente> incidentes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Monitor de Despositivos')),
      body: ListView(
          padding: const EdgeInsets.all(12),
          children: incidentes.map((incidente) => IncidenteCard(incidente: incidente)).toList(),
      ),
    );
  }
}