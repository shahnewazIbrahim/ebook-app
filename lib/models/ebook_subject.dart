class EbookSubject {
  final int id;
  final String title;
  final bool locked;

  EbookSubject({
    required this.id,
    required this.title,
    required this.locked,
  });

  factory EbookSubject.fromJson(Map<String, dynamic> json) {
    return EbookSubject(
      id: json['id'],
      title: json['title'],
      locked: json['locked'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'locked': locked,
    };
  }
}
