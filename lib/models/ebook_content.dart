class EbookContent {
  final int id;
  final String title;

  EbookContent({
    required this.id,
    required this.title,
  });

  factory EbookContent.fromJson(Map<String, dynamic> json) {
    return EbookContent(
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
