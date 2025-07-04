import 'package:flutter/material.dart';
import '../../models/alert_message_model.dart';
import '../../utils/alert_utils.dart';

class AlertDetailHeader extends StatelessWidget {
  final AlertMessage alert;

  const AlertDetailHeader({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final icon = AlertUtils.getIconLucid(alert.type);
    final color = AlertUtils.getAlertColor(alert.type);

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            radius: 30,
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            alert.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
