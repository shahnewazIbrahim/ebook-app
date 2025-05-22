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
        String answerKey = content.answer[index];
        String? selected = selectedAnswers[option.id];
        bool correctShown = showCorrect.contains(content.id);

        return Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: correctShown
                    ? (answerKey == 'T' ? Colors.green : Colors.red)
                    : (selected == 'T' ? Colors.blue : Colors.grey),
                minimumSize: const Size(36, 36), // ছোট উচ্চতা ও প্রস্থ
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // ভিতরের স্পেস
                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // tap এরিয়া কমানো
              ),
              onPressed: () {
                setState(() {
                  selectedAnswers[option.id] = 'T';
                });
              },
              child: const Text(
                'T',
                style: TextStyle(fontSize: 14), // লেখার সাইজ ছোট
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: correctShown
                    ? (answerKey == 'F' ? Colors.green : Colors.red)
                    : (selected == 'F' ? Colors.blue : Colors.grey),
                minimumSize: const Size(36, 36),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                setState(() {
                  selectedAnswers[option.id] = 'F';
                });
              },
              child: const Text(
                'F',
                style: TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(width: 8),
            Expanded(child: Html(data: option.title)),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: '${widget.ebookName} Questions',
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: ebookContents.length,
        itemBuilder: (context, index) {
          final content = ebookContents[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Html(data: content.title),
                  const SizedBox(height: 8),
                  buildOptionButtons(content),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showCorrect.add(content.id);
                          });
                        },
                        child: const Text("Answer"),
                      ),
                      const SizedBox(width: 8),
                      if (content.hasDiscussion)
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Discussion Modal
                          },
                          child: const Text("Discussion"),
                        ),
                      const SizedBox(width: 8),
                      if (content.hasReference)
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Reference Modal
                          },
                          child: const Text("Reference"),
                        ),
                      const SizedBox(width: 8),
                      if (content.hasSolveVideo)
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Solve Video Modal
                          },
                          child: const Text("Video"),
                        ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
