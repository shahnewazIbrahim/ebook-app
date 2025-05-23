import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/models/ebook_topic.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EbookTopicsPage extends StatefulWidget {
  final String ebookId;
  final String subjectId;
  final String chapterId;
  final String ebookName;

  const EbookTopicsPage(
      {super.key,
      required this.ebookId,
      required this.subjectId,
      required this.chapterId,
      required this.ebookName});

  @override
  _EbookTopicsState createState() => _EbookTopicsState();
}

class _EbookTopicsState extends State<EbookTopicsPage> {
  List<EbookTopic> ebookTopics = []; // Ensure this is initialized as a List
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchEbookTopics();
  }

  Future<void> fetchEbookTopics() async {
    ApiService apiService = ApiService();
    try {
      final data = await apiService.fetchEbookData(
          "/v1/ebooks/${widget.ebookId}/subjects/${widget.subjectId}/chapters/${widget.chapterId}/topics");
      setState(() {
        ebookTopics = (data['topics'] as List)
            .map((subjectJson) => EbookTopic.fromJson(subjectJson))
            .toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true; // Optional: handle error state
      });
      print("Error fetching ebook topics: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      // title: 'Ebook Topics',
      title: '${widget.ebookName} Topics',
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: ebookTopics.length,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  if (ebookTopics[index].title.isNotEmpty) {
                    return GestureDetector(
                      onTap: () {
                        // Add navigation logic to the 'Chapters' screen with parameters
                      },
                      child: Card(
                        color: Colors.grey[200],
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: [
                                      Colors.blue[200]!,
                                      Colors.blue[600]!
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                child: Icon(
                                  FontAwesomeIcons.book,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      ebookTopics[index].title,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink(); // Skip empty titles
                  }
                },
              ),
      ),
    );
  }
}
