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
        String answerKey = (index < content.answer.length) ? content.answer[index] : '';;
        String? selected = selectedAnswers[option.id];
        bool correctShown = showCorrect.contains(content.id);

        return Row(
          children: [
            if(content.type == 1)
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: correctShown
                          ? (answerKey == 'T' ? Colors.green[400] : Colors.red[400])
                          : (selected == 'T' ? Colors.blue[400] : Colors.grey[300]),
                      minimumSize: const Size(28, 28), // ছোট উচ্চতা ও প্রস্থ
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // ভিতরের স্পেস
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // tap এরিয়া কমানো
                    ),
                    onPressed: () {
                      setState(() {
                        if (selectedAnswers[option.id] == 'T') {
                          selectedAnswers.remove(option.id); // 🔁 রিমুভ করলে পুরোটাই রিসেট হয়
                        } else {
                          selectedAnswers[option.id] = 'T'; // ✅ নতুন করে সেট করো
                        }
                      });
                    },
                    child: Text(
                      'T',
                      style: TextStyle(
                          fontSize: 14,
                          color: correctShown ||  selectedAnswers[option.id] == 'T' ? Colors.white : Colors.black
                      ), // লেখার সাইজ ছোট
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: correctShown
                          ? (answerKey == 'F' ? Colors.green[400] : Colors.red[400])
                          : (selected == 'F' ? Colors.blue[400] : Colors.grey[300]),
                      minimumSize: const Size(28, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      setState(() {
                        if (selectedAnswers[option.id] == 'F') {
                          selectedAnswers.remove(option.id); // 🔁 রিমুভ করলে পুরোটাই রিসেট হয়
                        } else {
                          selectedAnswers[option.id] = 'F'; // ✅ নতুন করে সেট করো
                        }
                      });
                    },
                    child: Text(
                      'F',
                      style: TextStyle(
                        fontSize: 14,
                        color: correctShown || selectedAnswers[option.id] == 'F' ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

            if(content.type == 2)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: correctShown
                      ? (option.slNo == content.answer.toString() ? Colors.green[400] : Colors.red[400])
                      : (selected == option.slNo ? Colors.blue[400] : Colors.grey[300]),
                  minimumSize: const Size(28, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  setState(() {
                    if(selectedAnswers[option.id] == option.slNo) {
                      selectedAnswers.remove(option.id);
                    } else {
                      selectedAnswers[option.id] =  option.slNo;
                    }
                  });
                },
                child: Text(
                  option.slNo,
                  style: TextStyle(
                    fontSize: 14,
                    color: correctShown || selectedAnswers[option.id] == option.slNo ? Colors.white : Colors.black,
                  ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          minimumSize: const Size(35, 35), // ছোট উচ্চতা ও প্রস্থ
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // ভিতরের স্পেস
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // tap এরিয়া কমানো
                        ),
                        onPressed: () {
                          setState(() {
                            if (showCorrect.contains(content.id)) {
                              showCorrect.remove(content.id); // 🔁 উত্তর লুকাও
                            } else {
                              showCorrect.add(content.id); // ✅ উত্তর দেখাও
                            }
                          });
                        },
                        child: const Text(
                            "Answer",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            )),
                      ),
                      const SizedBox(width: 8),
                      if (content.hasDiscussion)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[400],
                            minimumSize: const Size(35, 35), // ছোট উচ্চতা ও প্রস্থ
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // ভিতরের স্পেস
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // tap এরিয়া কমানো
                          ),
                          onPressed: () {
                            // TODO: Discussion Modal
                          },
                          child: const Text(
                              "Discussion",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              )),
                        ),
                      const SizedBox(width: 8),
                      if (content.hasReference)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[400],
                            minimumSize: const Size(35, 35), // ছোট উচ্চতা ও প্রস্থ
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // ভিতরের স্পেস
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // tap এরিয়া কমানো
                          ),
                          onPressed: () {
                            // TODO: Reference Modal
                          },
                          child: const Text(
                              "Reference",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              )),
                        ),
                      const SizedBox(width: 8),
                      if (content.hasSolveVideo)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[400],
                            minimumSize: const Size(35, 35), // ছোট উচ্চতা ও প্রস্থ
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // ভিতরের স্পেস
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // tap এরিয়া কমানো
                          ),
                          onPressed: () {
                            // TODO: Solve Video Modal
                          },
                          child: const Text(
                              "Video",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              )),
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
