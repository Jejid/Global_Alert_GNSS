import 'package:flutter/material.dart';
import '../../models/alert_message_model.dart';
import '../../utils/alert_utils.dart';
import '../alert_detail_screen.dart';
import 'alert_card.dart';

class AlertsList extends StatelessWidget {
  final List<AlertMessage> alerts;

  const AlertsList({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Center(
        child: Text(
          'No hay alertas recientes.',
          style: TextStyle(color: Color(0xFF9ba1bb), fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AlertDetailScreen(alert: alert)),
            );
          },
          child: AlertCard(alert: alert),
        );
      },
    );
  }
}
