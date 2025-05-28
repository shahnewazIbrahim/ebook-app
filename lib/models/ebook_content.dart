class Option {
  final int id;
  final String slNo;
  final String title;

  Option({
    required this.id,
    required this.slNo,
    required this.title,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      slNo: json['sl_no'],
      title: json['title'],
    );
  }
}

class EbookContent {
  final int id;
  final String title;
  final int type;
  final int pageNo;
  final List<Option> options;
  final String answer;
  final bool hasDiscussion;
  final bool hasReference;
  final bool hasSolveVideo;
  final bool hasNote;

  EbookContent({
    required this.id,
    required this.title,
    required this.type,
    required this.pageNo,
    required this.options,
    required this.answer,
    required this.hasDiscussion,
    required this.hasReference,
    required this.hasSolveVideo,
    required this.hasNote,
  });

  factory EbookContent.fromJson(Map<String, dynamic> json) {
    return EbookContent(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      pageNo: json['page_no'],
      options: (json['options'] as List)
          .map((option) => Option.fromJson(option))
          .toList(),
      answer: json['answer'],
      hasDiscussion: json['has_discussion'],
      hasReference: json['has_reference'],
      hasSolveVideo: json['has_solve_video'],
      hasNote: json['has_note'],
    );
  }
}
