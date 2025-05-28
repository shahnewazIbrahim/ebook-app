import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/models/ebook_content.dart';

class EbookContentsPage extends StatefulWidget {
  final String ebookId;
  final String subjectId;
  final String chapterId;
  final String topicId;
  final String ebookName;

  const EbookContentsPage({
    super.key,
    required this.ebookId,
    required this.subjectId,
    required this.chapterId,
    required this.topicId,
    required this.ebookName,
  });

  @override
  State<EbookContentsPage> createState() => _EbookContentsPageState();
}

class _EbookContentsPageState extends State<EbookContentsPage> {
  List<EbookContent> ebookContents = [];
  bool isLoading = true;
  bool isError = false;
  Map<int, String> selectedAnswers = {};
  Set<int> showCorrect = {};

  @override
  void initState() {
    super.initState();
    fetchEbookContents();
  }

  Future<void> fetchEbookContents() async {
    ApiService apiService = ApiService();
    try {
      final data = await apiService.fetchEbookData(
        "/v1/ebooks/${widget.ebookId}/subjects/${widget.subjectId}/chapters/${widget.chapterId}/topics/${widget.topicId}/contents",
      );
      setState(() {
        ebookContents = (data['contents'] as List)
            .map((e) => EbookContent.fromJson(e))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Widget buildOptionButtons(EbookContent content) {
    return Column(
      children: content.options.asMap().entries.map((entry) {
        final option = entry.value;
        final index = entry.key;
        String answerKey = (index < content.answer.length) ? content.answer[index] : '';
        String? selected = selectedAnswers[option.id];
        bool correctShown = showCorrect.contains(content.id);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (content.type == 1) ...[
                buildTFButton(option, 'T', selected, correctShown, answerKey),
                const SizedBox(width: 6),
                buildTFButton(option, 'F', selected, correctShown, answerKey),
              ],
              if (content.type == 2)
                buildSingleOptionButton(option, selected, correctShown, content.answer),
              const SizedBox(width: 10),
              Expanded(child: Html(data: option.title)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildTFButton(option, String label, String? selected, bool correctShown, String answerKey) {
    final bool isSelected = selected == label;
    final bool isCorrect = answerKey == label;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: correctShown
            ? (isCorrect ? Colors.green[700] : Colors.red[700])
            : (isSelected ? Colors.blue[700] : Colors.grey[300]),
        minimumSize: const Size(28, 28),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: const BorderSide(color: Colors.black26, width: 1.5),
        ),
      ),
      onPressed: () {
        setState(() {
          selectedAnswers[option.id] = isSelected ? '' : label;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: correctShown || isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget buildSingleOptionButton(option, String? selected, bool correctShown, String answer) {
    final bool isSelected = selected == option.slNo;
    final bool isCorrect = option.slNo == answer;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: correctShown
            ? (isCorrect ? Colors.green[700] : Colors.red[700])
            : (isSelected ? Colors.blue[700] : Colors.grey[300]),
        minimumSize: const Size(28, 28),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: const BorderSide(color: Colors.black26, width: 1.5),
        ),
      ),
      onPressed: () {
        setState(() {
          selectedAnswers[option.id] = isSelected ? '' : option.slNo;
        });
      },
      child: Text(
        option.slNo,
        style: TextStyle(
          fontSize: 14,
          color: correctShown || isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget buildImageContent(String htmlString) {
    final RegExp exp = RegExp(r'<img[^>]+src="([^">]+)"');
    final match = exp.firstMatch(htmlString);
    final imageUrl = match?.group(1);

    if (imageUrl == null) {
      return const Text('Image not found');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: '${widget.ebookName} Questions',
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: ebookContents.length,
        itemBuilder: (context, index) {
          final content = ebookContents[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  content.type == 3
                      ? buildImageContent(content.title)
                      : Html(data: "<b>${content.title}</b>"),
                  const SizedBox(height: 10),
                  buildOptionButtons(content),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      buildActionButton(
                        label: "Answer",
                        onTap: () {
                          setState(() {
                            if (showCorrect.contains(content.id)) {
                              showCorrect.remove(content.id);
                            } else {
                              showCorrect.add(content.id);
                            }
                          });
                        },
                        isActive: showCorrect.contains(content.id),
                      ),
                      if (content.hasDiscussion)
                        buildActionButton(label: "Discussion", onTap: () {}, isActive: false),
                      if (content.hasReference)
                        buildActionButton(label: "Reference", onTap: () {}, isActive: false),
                      if (content.hasSolveVideo)
                        buildActionButton(label: "Video", onTap: () {}, isActive: false),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildActionButton({
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue[800] : Colors.blue[500],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, color: Colors.white),
      ),
    );
  }
}
