import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/ebook_topics.dart';
import 'package:ebook_project/models/ebook_chapter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EbookChaptersPage extends StatefulWidget {
  final String ebookId;
  final String subjectId;
  final String ebookName;

  const EbookChaptersPage({
    super.key,
    required this.ebookId,
    required this.subjectId,
    required this.ebookName,
  });

  @override
  _EbookChaptersState createState() => _EbookChaptersState();
}

class _EbookChaptersState extends State<EbookChaptersPage> {
  List<EbookChapter> ebookChapters = [];
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
        "/v1/ebooks/${widget.ebookId}/subjects/${widget.subjectId}/chapters",
      );
      setState(() {
        ebookChapters = (data['chapters'] as List)
            .map((chapterJson) => EbookChapter.fromJson(chapterJson))
            .toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      print("Error fetching ebook chapters: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: '${widget.ebookName} Chapters',
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(child: Text('Failed to load chapters'))
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: ebookChapters.isEmpty
            ? const Center(
          child: Text(
            'No Chapters Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : ListView.builder(
          itemCount: ebookChapters.length,
          itemBuilder: (context, index) {
            final chapter = ebookChapters[index];

            if (chapter.title.isEmpty) {
              return const SizedBox.shrink();
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EbookTopicsPage(
                      ebookId: widget.ebookId,
                      subjectId: widget.subjectId,
                      chapterId: chapter.id.toString(),
                      ebookName: widget.ebookName,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFe0f2fe), Color(0xFFbae6fd)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          colors: [Color(0xFF0ea5e9), Color(0xFF0369a1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: const Icon(
                        FontAwesomeIcons.book,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Text(
                        chapter.title,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0f172a),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
