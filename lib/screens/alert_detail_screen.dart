import 'package:flutter/material.dart';
import 'package:global_alert_gnss/models/alert_message_model.dart';
import '../utils/alert_utils.dart';

class AlertDetailScreen extends StatelessWidget {
  final AlertMessage alert;

  const AlertDetailScreen({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final icon = AlertUtils.getIconLucid(alert.type);
    final color = AlertUtils.getAlertColor(alert.type);

    Text buildFieldTitle(String text) => Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );

    Text buildFieldContent(String text) => Text(
      text,
      style: const TextStyle(fontSize: 16),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(alert.title),
        backgroundColor: color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con ícono y tipo
                Row(
                  children: [
                    Icon(icon, size: 32, color: color),
                    const SizedBox(width: 12),
                    Text(
                      alert.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),

                // Mensaje principal
                buildFieldTitle("Mensaje:"),
                buildFieldContent(alert.message),
                const SizedBox(height: 16),

                buildFieldTitle("Fecha de emisión:"),
                buildFieldContent(AlertUtils.formatDate(alert.timestamp)),
                const SizedBox(height: 16),

                if (alert.regions != null && alert.regions!.isNotEmpty) ...[
                  buildFieldTitle("Región(es):"),
                  buildFieldContent(alert.regions!.join(", ")),
                  const SizedBox(height: 16),
                ],

                if (alert.locations != null && alert.locations!.isNotEmpty) ...[
                  buildFieldTitle("Ubicación aproximada:"),
                  buildFieldContent(
                    alert.locations!
                        .map((l) => '${l.lat}, ${l.lon}')
                        .join("  |  "),
                  ),
                  const SizedBox(height: 16),
                ],

                if (alert.validUntil != null) ...[
                  buildFieldTitle("Válido hasta:"),
                  buildFieldContent(AlertUtils.formatDate(alert.validUntil!)),
                  const SizedBox(height: 16),
                ],

                const Spacer(),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Función de mapa no disponible aún")),
                      );
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text("Ver en el mapa"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
