class AlertMessage {
  final String title;
  final String message;

  AlertMessage({required this.title, required this.message});

  factory AlertMessage.fromJson(Map<String, dynamic> json) {
    return AlertMessage(
      title: json['title'],
      message: json['message'],
    );
  }
}
