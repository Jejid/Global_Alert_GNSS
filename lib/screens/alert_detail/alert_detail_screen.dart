import 'package:flutter/material.dart';
import '../../models/alert_message_model.dart';
import 'alert_detail_sections.dart';

class AlertDetailScreen extends StatelessWidget {
  final AlertMessage alert;

  const AlertDetailScreen({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0F14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          alert.type.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: AlertDetailSections(alert: alert),
    );
  }
}
