import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/custom_app_bar.dart';
import 'package:ebook_project/components/custom_drawer.dart';
import 'package:ebook_project/ebook_topics.dart';
import 'package:ebook_project/models/ebook_chapter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EbookChaptersPage extends StatefulWidget {
  final String ebookId;
  final String subjectId;

  const EbookChaptersPage(
      {super.key, required this.ebookId, required this.subjectId});

  @override
  _EbookChaptersState createState() => _EbookChaptersState();
}

class _EbookChaptersState extends State<EbookChaptersPage> {
  List<EbookChapter> ebookChapters = []; // Ensure this is initialized as a List
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchEbookChapters();
  }

  Future<void> fetchEbookChapters() async {
    ApiService apiService = ApiService();
    try {
      final data = await apiService.fetchEbookData(
          "/v1/ebooks/${widget.ebookId}/subjects/${widget.subjectId}/chapters");
      setState(() {
        ebookChapters = (data['chapters'] as List)
            .map((subjectJson) => EbookChapter.fromJson(subjectJson))
            .toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true; // Optional: handle error state
      });
      print("Error fetching ebook chapters: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Ebook Chapters',
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: ebookChapters.length,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  if (ebookChapters[index].title.isNotEmpty) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EbookTopicsPage(
                              ebookId: widget.ebookId,
                              subjectId: widget.subjectId,
                              chapterId: ebookChapters[index].id.toString(),
                            ),
                          ),
                        );
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
                                      ebookChapters[index].title,
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
