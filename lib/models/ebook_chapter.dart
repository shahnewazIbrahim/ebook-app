class EbookChapter {
  final int id;
  final String title;

  EbookChapter({
    required this.id,
    required this.title,
  });

  factory EbookChapter.fromJson(Map<String, dynamic> json) {
    return EbookChapter(
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
