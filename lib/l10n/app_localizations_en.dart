// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get viewAlerts => 'View Alerts';

  @override
  String get validUntil => 'Valid until:';

  @override
  String get region => 'Region:';

  @override
  String get regions => 'Regions:';

  @override
  String get loadingError => 'Error loading alerts';
}
