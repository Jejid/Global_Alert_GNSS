// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get alertsTitle => 'Alertas';

  @override
  String get viewAlerts => 'Ver Alertas';

  @override
  String get validUntil => 'Válido hasta:';

  @override
  String get region => 'Región:';

  @override
  String get regions => 'Regiones:';

  @override
  String get loadingError => 'Error al cargar alertas';

  @override
  String get appTitle => 'Alertas Globales GNSS';

  @override
  String get recentAlerts => 'Alertas Recientes';

  @override
  String get noRecentAlerts => 'No hay alertas recientes';

  @override
  String get alertMap => 'Mapa de Alertas';

  @override
  String get history => 'Alertas';

  @override
  String get filterByType => 'Filtrar por tipo de Alerta';

  @override
  String get home => 'Principal';

  @override
  String get searchAlerts => 'Buscar Alertas';
}
