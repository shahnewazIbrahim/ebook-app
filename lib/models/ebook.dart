class Ebook {
  final int id;
  final int subcriptionId;
  final String image;
  final String name;
  final int status;
  final String validity;
  final String ending;
  final Button? button;
  final String statusText;
  final bool isExpired;

  Ebook({
    required this.id,
    required this.subcriptionId,
    required this.image,
    required this.name,
    required this.status,
    required this.validity,
    required this.ending,
    this.button,
    required this.statusText,
    required this.isExpired,
  });

  factory Ebook.fromJson(Map<String, dynamic> json) {
    return Ebook(
      id: json['id'],
      subcriptionId: json['subcriptionId'],
      image: json['image'],
      name: json['name'],
      status: json['status'],
      validity: json['validity'],
      ending: json['ending'],
      button: json['button'] != null ? Button.fromJson(json['button']) : null,
      statusText: json['statusText'] ?? '',
      isExpired: json['isExpired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subcriptionId': subcriptionId,
      'image': image,
      'name': name,
      'status': status,
      'validity': validity,
      'ending': ending,
      'button': button?.toJson(),
      'statusText': statusText,
      'isExpired': isExpired,
    };
  }
}

class Button {
  final String link;
  final String value;
  final bool status;

  Button({
    required this.link,
    required this.value,
    required this.status,
  });

  factory Button.fromJson(Map<String, dynamic> json) {
    return Button(
      link: json['link'],
      value: json['value'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'link': link,
      'value': value,
      'status': status,
    };
  }
}
