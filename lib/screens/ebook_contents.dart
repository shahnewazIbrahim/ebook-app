import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/models/ebook_content.dart';

// new components
import 'package:ebook_project/components/contents/content_card.dart';
import 'package:ebook_project/components/contents/skeletons.dart';
import 'package:ebook_project/components/contents/app_modal.dart';
import 'package:ebook_project/screens/youtube_player_page.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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

  // selections
  final Map<int, String> selectedAnswers = {};
  final Map<int, String> selectedSBAAnswers = {};
  final Set<int> showCorrect = {};

  // modals
  bool showModalLoader = false;
  String discussionContent = '';
  bool showDiscussionModal = false;
  List<Map<String, dynamic>> solveVideos = [];
  bool showVideoModal = false;

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

  Future<void> fetchDiscussionContent(String contentId) async {
    setState(() => showModalLoader = true);
    ApiService apiService = ApiService();
    try {
      final response = await apiService.fetchRawTextData(
          "/v1/ebooks/${widget.ebookId}/subjects/${widget.subjectId}/chapters/${widget.chapterId}/topics/${widget.topicId}/contents/$contentId/discussion"
      );
      setState(() {
        discussionContent = response;
        showDiscussionModal = true;
        showModalLoader = false;
      });
    } catch (e) {
      setState(() => showModalLoader = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load discussion"))
      );
    }
  }

  Future<void> fetchSolveVideos(String contentId) async {
    setState(() => showModalLoader = true);
    ApiService apiService = ApiService();
    try {
      final data = await apiService.fetchEbookData(
          "/v1/ebooks/${widget.ebookId}/subjects/${widget.subjectId}/chapters/${widget.chapterId}/topics/${widget.topicId}/contents/$contentId/solve-videos");

      solveVideos = (data['solve_videos'] as List)
          .map((e) => {
        'title': e['title'] ?? 'Video',
        'video_url': e['link'] ?? e['video_url'],
      })
          .where((v) => v['video_url'] != null)
          .toList();

      setState(() {
        showVideoModal = true;
        showModalLoader = false;
      });
    } catch (e) {
      setState(() => showModalLoader = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to load videos")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppLayout(
          title: '${widget.ebookName} Questions',
          body: isLoading
              ? ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, _) => const EbookSkeletonCard(),
          )
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            itemCount: ebookContents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final content = ebookContents[index];
              return ContentCard(
                content: content,
                showCorrect: showCorrect.contains(content.id),
                selectedTF: selectedAnswers,
                selectedSBA: selectedSBAAnswers,
                onToggleAnswer: () {
                  setState(() {
                    showCorrect.contains(content.id)
                        ? showCorrect.remove(content.id)
                        : showCorrect.add(content.id);
                  });
                },
                onTapDiscussion: content.hasDiscussion
                    ? () => fetchDiscussionContent(content.id.toString())
                    : null,
                onTapVideo: content.hasSolveVideo
                    ? () => fetchSolveVideos(content.id.toString())
                    : null,
                onChooseTF: (optionId, label) {
                  setState(() {
                    final sel = selectedAnswers[optionId];
                    selectedAnswers[optionId] =
                    (sel == label) ? '' : label;
                  });
                },
                onChooseSBA: (contentId, slNo) {
                  setState(() {
                    final sel = selectedSBAAnswers[contentId];
                    selectedSBAAnswers[contentId] =
                    (sel == slNo) ? '' : slNo;
                  });
                },
              );
            },
          ),
        ),

        if (showDiscussionModal)
          AppModal(
            title: 'Discussion',
            onClose: () => setState(() => showDiscussionModal = false),
            child: SingleChildScrollView(
              child: Html(
                data: discussionContent,
                style: {
                  "*": Style(
                    backgroundColor: Colors.transparent,
                    fontSize: FontSize.medium,
                    color: Colors.black,
                  ),
                  "p": Style(margin: Margins.only(bottom: 6)),
                },
              ),
            ),
          ),

        if (showVideoModal)
          AppModal(
            title: 'Solve Videos',
            onClose: () => setState(() => showVideoModal = false),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: solveVideos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final v = solveVideos[i];
                final title = "${v['title']} ${i + 1}";
                final url = v['video_url'];
                final videoId = YoutubePlayer.convertUrlToId(url ?? '');

                if (url == null || videoId == null) {
                  return const ListTile(
                    leading: Icon(Icons.error, color: Colors.red),
                    title: Text('Invalid video URL'),
                  );
                }
                return ListTile(
                  leading: const Icon(Icons.play_circle_fill, size: 32),
                  title: Text(title, style: const TextStyle(fontSize: 14)),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => YoutubePlayerPage(videoId: videoId),
                    ));
                  },
                );
              },
            ),
          ),

        if (showModalLoader) const AppModalLoader(),
      ],
    );
  }
}
