import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/gnss_stream_service.dart';
import 'alerts_controller.dart';
import 'alerts_sections.dart';

class AlertsListScreen extends StatelessWidget {
  const AlertsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlertsController(gnssService: GnssStreamService())..init(),
      child: const AlertsSections(),
    );
  }
}
