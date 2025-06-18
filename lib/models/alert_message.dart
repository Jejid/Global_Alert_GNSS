class AlertMessage {
  final String id;
  final String type;
  final String title;
  final String scope;
  final Map<String, dynamic>? target; // puede incluir "mac", "groupId", etc.
  final DateTime timestamp;
  final String message;
  final List<String>? regions;
  final List<Location>? locations;
  final String language;
  final String source;
  final String priority;
  final DateTime? validUntil;

  AlertMessage({
    required this.id,
    required this.type,
    required this.title,
    required this.scope,
    this.target,
    required this.timestamp,
    required this.message,
    this.regions,
    this.locations,
    required this.language,
    required this.source,
    required this.priority,
    this.validUntil,
  });

  factory AlertMessage.fromJson(Map<String, dynamic> json) {
    return AlertMessage(
      id: json['id'] ?? '',
      type: json['type'],
      title: json['title'] ?? 'Sin título',
      scope: json['scope'],
      target: json['target'],
      timestamp: DateTime.parse(json['timestamp']),
      message: json['message'] ?? '',
      regions: json['regions'] != null ? List<String>.from(json['regions']) : null,
      locations: json['locations'] != null
          ? List<Location>.from(json['locations'].map((loc) => Location.fromJson(loc)))
          : null,
      language: json['language'],
      source: json['source'],
      priority: json['priority'] ?? 'normal',
      validUntil: json['valid_until'] != null ? DateTime.parse(json['valid_until']) : null,
    );
  }
}

class Location {
  final double lat;
  final double lon;
  final double radiusKm;

  Location({
    required this.lat,
    required this.lon,
    required this.radiusKm,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'],
      lon: json['lon'],
      radiusKm: json['radius_km'].toDouble(),
    );
  }
}
