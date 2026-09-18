import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'models/incidente.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      title: 'Central de Incidentes',
      home: HomeScreen(
        incidentes: [
          Incidente(
            id: 'INC-1045',
            titulo: 'Login falho repetido — conta admin',
            tipo: 'Acesso não autorizado',
            severidade: IncidenteSeveridade.critico,
            status: IncidenteStatus.aberto,
            abertoEm: agora.subtract(const Duration(minutes: 15)),
          ),
          Incidente(
            id: 'INC-1044',
            titulo: 'Acesso fora do horário — VPN corporativa',
            tipo: 'Acesso não autorizado',
            severidade: IncidenteSeveridade.critico,
            status: IncidenteStatus.aberto,
            abertoEm: agora.subtract(const Duration(minutes: 40)),
            responsavel: 'Ana Souza',
          ),
          Incidente(
            id: 'INC-1042',
            titulo: 'Tentativa de phishing — portal de RH',
            tipo: 'Phishing',
            severidade: IncidenteSeveridade.alto,
            status: IncidenteStatus.emAndamento,
            abertoEm: agora.subtract(const Duration(hours: 3)),
            responsavel: 'Ana Souza',
          ),
          Incidente(
            id: 'INC-1039',
            titulo: 'Malware detectado — estação FIN-07',
            tipo: 'Malware',
            severidade: IncidenteSeveridade.alto,
            status: IncidenteStatus.emAndamento,
            abertoEm: agora.subtract(const Duration(days: 1, hours: 2)),
            responsavel: 'Carlos Lima',
          ),
          Incidente(
            id: 'INC-1031',
            titulo: 'Picos de tráfego — API pública',
            tipo: 'DDoS',
            severidade: IncidenteSeveridade.medio,
            status: IncidenteStatus.resolvido,
            abertoEm: agora.subtract(const Duration(days: 2, hours: 5)),
            responsavel: 'Ana Souza',
          ),
          Incidente(
            id: 'INC-1027',
            titulo: 'Certificado TLS expirado — intranet',
            tipo: 'Outro',
            severidade: IncidenteSeveridade.baixo,
            status: IncidenteStatus.resolvido,
            abertoEm: agora.subtract(const Duration(days: 4)),
            responsavel: 'Carlos Lima',
          ),
        ],
      ),
      
    ),
  );
}
