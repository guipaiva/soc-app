import 'package:flutter/material.dart';

import '../models/incidente.dart';

class IncidenteCard extends StatelessWidget {
  const IncidenteCard({
    super.key,
    required this.incidente,
    required this.onTap,
  });

  final Incidente incidente;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final corSeveridade = corDaSeveridade(incidente.severidade);
    final corStatus = corDoStatus(incidente.status);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      textoDaSeveridade(incidente.severidade),
                      style: TextStyle(
                        color: corSeveridade,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: corSeveridade.withValues(alpha: 0.14),
                    side: BorderSide(color: corSeveridade),
                  ),
                  Text(
                    incidente.abertoHa,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    iconeDaSeveridade(incidente.severidade),
                    color: corSeveridade,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      incidente.titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '#${incidente.id} · ${incidente.tipo}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      incidente.status.texto,
                      style: TextStyle(
                        color: corStatus,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  Text(incidente.responsavel ?? 'Sem responsável'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
