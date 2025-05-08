class EbookSubject {
  final int id;
  final String title;

  EbookSubject({
    required this.id,
    required this.title,
  });

  factory EbookSubject.fromJson(Map<String, dynamic> json) {
    return EbookSubject(
      id: json['id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}
