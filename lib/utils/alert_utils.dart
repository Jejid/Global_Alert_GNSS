import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/alert_message_model.dart';
import '../services/alert_service.dart';

class AlertUtils {
  /// Devuelve un color de marcador basado en el tipo de alerta.
  static double getHue_forType(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return BitmapDescriptor.hueRed;
      case 'earthquake':
        return BitmapDescriptor.hueOrange;
      case 'flood':
        return BitmapDescriptor.hueAzure;
      case 'medical':
        return BitmapDescriptor.hueRose;
      case 'rescue':
        return BitmapDescriptor.hueViolet;
      case 'tsunami':
        return BitmapDescriptor.hueCyan;
      case 'missing':
        return BitmapDescriptor.hueYellow;
      case 'storm':
        return BitmapDescriptor.hueMagenta;
      case 'conflict':
        return BitmapDescriptor.hueBlue;
      case 'hurricane':
        return BitmapDescriptor.hueGreen;
      case 'emergency':
        return BitmapDescriptor.hueRed;
      case 'evacuation':
        return BitmapDescriptor.hueYellow;
      case 'test':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  /// Formatea una fecha para mostrarla en la UI
  static String formatDate(DateTime date) {
    return DateFormat.yMMMMd().add_jm().format(date.toLocal());
  }

  /// Devuelve un color de fondo para el tipo de alerta
  static Color getAlertColor(String type) {
    switch (type) {
      case 'rescue':
        return Colors.blue.shade300;
      case 'fire':
        return Colors.red.shade400;
      case 'earthquake':
        return Colors.brown.shade400;
      case 'tsunami':
        return Colors.indigo.shade400;
      case 'missing':
        return const Color(0xFFD8B573);
      case 'storm':
        return Colors.deepPurple.shade300;
      case 'conflict':
        return const Color(0xFF807D78);
      case 'hurricane':
        return Colors.teal.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  /// Íconos estándar para cada tipo de alerta
  static IconData getAlertIcon(String type) {
    switch (type) {
      case 'rescue':
        return Icons.volunteer_activism;
      case 'fire':
        return Icons.local_fire_department;
      case 'earthquake':
        return Icons.waves;
      case 'tsunami':
        return Icons.water;
      case 'missing':
        return Icons.person_search;
      case 'storm':
        return Icons.bolt;
      case 'conflict':
        return Icons.security;
      case 'hurricane':
        return Icons.cyclone;
      default:
        return Icons.warning;
    }
  }

  /// Íconos estilo Lucide para cada tipo de alerta
  static IconData getIconLucid(String type) {
    switch (type) {
      case 'rescue':
        return LucideIcons.cross;
      case 'tsunami':
        return LucideIcons.waves;
      case 'fire':
        return LucideIcons.flame;
      case 'earthquake':
        return LucideIcons.activity;
      case 'missing':
        return LucideIcons.search;
      case 'storm':
        return LucideIcons.zap;
      case 'conflict':
        return LucideIcons.shieldAlert;
      case 'hurricane':
        return LucideIcons.tornado;
      default:
        return LucideIcons.alertCircle;
    }
  }

  /// Obtiene todas las alertas disponibles del archivo local
  static Future<List<AlertMessage>> getAllAlerts() async {
    try {
      return await AlertService.loadAlerts();
    } catch (e) {
      print('Error al cargar alertas: $e');
      return [];
    }
  }
}
