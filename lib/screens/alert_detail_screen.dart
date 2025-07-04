import 'package:flutter/material.dart';
import 'package:global_alert_gnss/models/alert_message_model.dart';
import '../utils/alert_utils.dart';
import 'map/map_screen.dart';
import '../l10n/app_localizations.dart';

class AlertDetailScreen extends StatelessWidget {
  final AlertMessage alert;

  const AlertDetailScreen({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final icon = AlertUtils.getIconLucid(alert.type);
    final color = AlertUtils.getAlertColor(alert.type);
    final loc = AppLocalizations.of(context)!;

    const backgroundColor = Color(0xFF0E0F14);
    const cardColor = Color(0xFF1A1C24);
    const textWhite = Colors.white;
    const textGray = Color(0xFF9ba1bb);

    final sectionTitleStyle = const TextStyle(
      color: textWhite,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );

    final labelStyle = const TextStyle(
      color: textGray,
      fontSize: 14,
    );

    final valueStyle = const TextStyle(
      color: textWhite,
      fontSize: 14,
    );

    final detailTextStyle = const TextStyle(
      color: textWhite,
      fontSize: 16,
      height: 1.4,
    );

    Widget buildDetailCard(String label, String value) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: ', style: labelStyle),
            Expanded(child: Text(value, style: valueStyle)),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            alert.type.toUpperCase(),
            key: ValueKey(alert.type),
            style: const TextStyle(
              color: textWhite,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono + Título
              Center(
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
              ),
              const SizedBox(height: 28),

              // Mensaje
              Text(loc.message, style: sectionTitleStyle),
              const SizedBox(height: 10),
              Text(alert.message, style: detailTextStyle),
              const SizedBox(height: 28),

              // Botón moderno
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapScreen(alerts: [alert]),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_rounded, size: 20),
                  label: Text(loc.lookInMap),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                    shadowColor: color.withOpacity(0.4),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Información adicional
              Text(loc.alertInformation, style: sectionTitleStyle),
              const SizedBox(height: 12),
              buildDetailCard(
                  loc.regions,
                  alert.regions
                      ?.toString()
                      .replaceAll('[', '')
                      .replaceAll(']', '') ??
                      'N/A'),
              buildDetailCard(
                  loc.timestamp, AlertUtils.formatDate(alert.timestamp)),
              buildDetailCard(loc.alertPriority, alert.priority ?? 'N/A'),
              buildDetailCard(loc.source, alert.source ?? 'N/A'),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
