import 'package:flutter/material.dart';
import 'package:global_alert_gnss/models/alert_message_model.dart';
import '../utils/alert_utils.dart';
import 'map_screen.dart';
import '../l10n/app_localizations.dart';

class AlertDetailScreen extends StatelessWidget {
  final AlertMessage alert;

  const AlertDetailScreen({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final icon = AlertUtils.getIconLucid(alert.type);
    final color = AlertUtils.getAlertColor(alert.type);

    final loc = AppLocalizations.of(context)!;

    // Colores del diseño
    const backgroundColor = Color(0xFF111218);
    const borderColor = Color(0xFF3a3f55);
    const textWhite = Colors.white;
    const textGray = Color(0xFF9ba1bb);
    const buttonBlue = Color(0xFF4264fa);

    TextStyle sectionTitleStyle = const TextStyle(
      color: textWhite,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      height: 1.2,
      letterSpacing: -0.015,
    );

    TextStyle labelStyle = const TextStyle(
      color: textGray,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.1,
    );

    TextStyle valueStyle = const TextStyle(
      color: textWhite,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.1,
    );

    TextStyle detailTextStyle = const TextStyle(
      color: textWhite,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.4,
    );

    Widget buildDetailRow(String label, String value) {
      return Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Text(label, style: labelStyle),
            ),
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
          icon: const Icon(Icons.arrow_back, color: textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Título dinámico: tipo de alerta en mayúsculas
        title: Text(
          alert.type.toUpperCase(),
          style: const TextStyle(
            color: textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
              // Título centrado con icono y tipo alerta
            Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 32, color: color),
                      const SizedBox(width: 12),
                      Text(
                      alert.title.toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: -0.015,
                        ),
                      ),
                    ],
                  ),
            ),

              // Sección Details (mensaje)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(loc.message, style: sectionTitleStyle),
                    const SizedBox(height: 8),
                    Text(
                      alert.message,
                      style: detailTextStyle,
                    ),
                    const SizedBox(height: 24),

            // Botón "Look in Map"
                      SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.015,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapScreen(alerts: [alert]),
                      ),
                    );
                  },
                          child: Text(loc.lookInMap,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Sección Alert Information (grid)
                      Text(loc.alertInformation, style: sectionTitleStyle),
                      const SizedBox(height: 12),

                      buildDetailRow(loc.regions, alert.regions.toString().replaceAll('[', '').replaceAll(']', '') ?? 'N/A'),
                      buildDetailRow(loc.timestamp,
                          AlertUtils.formatDate(alert.timestamp)),
                      buildDetailRow(
                          loc.alertPriority, alert.priority ?? 'N/A'),
                      buildDetailRow(loc.source, alert.source ?? 'N/A'),

                      const SizedBox(height: 24),
                    ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
