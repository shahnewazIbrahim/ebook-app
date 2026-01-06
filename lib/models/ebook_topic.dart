class EbookTopic {
  final int id;
  final String title;
  final bool locked;

  EbookTopic({
    required this.id,
    required this.title,
    required this.locked,
  });

  factory EbookTopic.fromJson(Map<String, dynamic> json) {
    return EbookTopic(
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
