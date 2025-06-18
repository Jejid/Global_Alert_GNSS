import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat.yMMMMd().add_jm().format(date.toLocal());
}


Color getAlertColor(String type) {
  switch (type) {
    case 'rescue':
      return Colors.blue.shade300;
    case 'fire':
      return Colors.red.shade400;
    case 'earthquake':
      return Color(0xFFBD7B1A);
    case 'tsunami':
      return Colors.indigo.shade400;
    case 'missing':
      return Color(0xFFD8B573);
    default:
      return Colors.grey.shade400;
  }
}

IconData getAlertIcon(String type) {
  switch (type) {
    case 'rescue':
      return Icons.volunteer_activism; // manos ayudando
    case 'fire':
      return Icons.local_fire_department;
    case 'earthquake':
      return Icons.waves; // o Icons.crisis_alert (Flutter 3.7+)
    case 'tsunami':
      return Icons.water;
    case 'missing':
      return Icons.person_search;
    default:
      return Icons.warning;
  }
}

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
      default:
        return LucideIcons.alertCircle;
    }
  }
