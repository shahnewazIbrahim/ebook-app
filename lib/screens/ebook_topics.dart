import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/components/shimmer_list_loader.dart';
import 'package:ebook_project/screens/ebook_contents.dart';
import 'package:ebook_project/models/ebook_topic.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EbookTopicsPage extends StatefulWidget {
  final String ebookId;
  final String subjectId;
  final String chapterId;
  final String ebookName;

  const EbookTopicsPage({
    super.key,
    required this.ebookId,
    required this.subjectId,
    required this.chapterId,
    required this.ebookName,
  });

  @override
  _EbookTopicsState createState() => _EbookTopicsState();
}

class _EbookTopicsState extends State<EbookTopicsPage> {
  List<EbookTopic> ebookTopics = [];
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
        "/v1/ebooks/${widget.ebookId}/subjects/${widget.subjectId}/chapters/${widget.chapterId}/topics",
      );
      setState(() {
        ebookTopics = (data['topics'] as List)
            .map((topicJson) => EbookTopic.fromJson(topicJson))
            .toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      print("Error fetching ebook topics: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: '${widget.ebookName} Topics',
      body: isLoading
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: ShimmerListLoader(),
            )
          : isError
          ? const Center(child: Text('Failed to load topics'))
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: ebookTopics.isEmpty
            ? const Center(
          child: Text(
            'No Topics Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : ListView.builder(
          itemCount: ebookTopics.length,
          itemBuilder: (context, index) {
            final topic = ebookTopics[index];

            if (topic.title.isEmpty) {
              return const SizedBox.shrink();
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EbookContentsPage(
                      ebookId: widget.ebookId,
                      subjectId: widget.subjectId,
                      chapterId: widget.chapterId,
                      topicId: topic.id.toString(),
                      ebookName: widget.ebookName,
                    ),
                  ),
                );
              },
              child: Container(
                margin:
                const EdgeInsets.symmetric(vertical: 8.0),
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
                        topic.title,
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
