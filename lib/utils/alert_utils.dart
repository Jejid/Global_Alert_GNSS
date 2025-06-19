import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat.yMMMMd().add_jm().format(date.toLocal());
}

// 🎨 Colores por tipo de alerta
Color getAlertColor(String type) {
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
      return const Color(0xFFD8B573); // mostaza claro
    case 'storm':
      return Colors.deepPurple.shade300; // púrpura eléctrico
    case 'conflict':
      return const Color(0xFF807D78); // marrón conflicto
    case 'hurricane':
      return Colors.teal.shade400; // color distintivo tipo ciclón
    default:
      return Colors.grey.shade400;
  }
}

// 🧭 Íconos estándar de Flutter
IconData getAlertIcon(String type) {
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

// 🌀 Íconos estilo Lucide
IconData getIconLucid(String type) {
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
