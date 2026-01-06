class EbookChapter {
  final int id;
  final String title;
  final bool locked;

  EbookChapter({
    required this.id,
    required this.title,
    required this.locked,
  });

  factory EbookChapter.fromJson(Map<String, dynamic> json) {
    return EbookChapter(
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
