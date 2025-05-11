class EbookTopic {
  final int id;
  final String title;

  EbookTopic({
    required this.id,
    required this.title,
  });

  factory EbookTopic.fromJson(Map<String, dynamic> json) {
    return EbookTopic(
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
