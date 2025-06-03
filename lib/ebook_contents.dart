import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/models/ebook_content.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shimmer/shimmer.dart';

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
    ApiService apiService = ApiService();
    try {
      final response = await apiService.fetchRawTextData(
          "/v1/ebooks/${widget.ebookId}/subjects/${widget.subjectId}/chapters/${widget.chapterId}/topics/${widget.topicId}/contents/$contentId/discussion"
      );
      setState(() {
        discussionContent = response;
        showDiscussionModal = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load discussion"))
      );
    }
  }

  Future<void> fetchSolveVideos(String contentId) async {
    ApiService apiService = ApiService();
    try {
      final data = await apiService.fetchEbookData(
          "/v1/ebooks/${widget.ebookId}/subjects/${widget.subjectId}/chapters/${widget.chapterId}/topics/${widget.topicId}/contents/$contentId/solve-videos");

      solveVideos = (data['solve_videos'] as List)
          .map((e) => {
        'title': e['title'] ?? 'Video',
        'video_url': e['link'] ?? e['link'], // 'link' or 'video_url' যে টা আসে
      })
          .where((v) => v['video_url'] != null)
          .toList();

      setState(() {
        showVideoModal = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load videos")));
    }
  }

  Widget buildSkeletonCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 20, width: double.infinity, color: Colors.white),
              const SizedBox(height: 10),
              Container(height: 14, width: double.infinity, color: Colors.white),
              const SizedBox(height: 8),
              Container(height: 14, width: 200, color: Colors.white),
              const SizedBox(height: 12),
              Row(
                children: List.generate(
                  3,
                      (index) => Container(
                    margin: const EdgeInsets.only(right: 10),
                    height: 30,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildVideoModal() {
    if (!showVideoModal) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => setState(() => showVideoModal = false),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
        ),
        Center(
          child: Material(
            borderRadius: BorderRadius.circular(16),
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.90,
              height: 480,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 20,
                    spreadRadius: 5,
                    color: Colors.black26,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.ondemand_video, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Solve Videos",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => showVideoModal = false),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      )
                    ],
                  ),
                  const Divider(height: 24, thickness: 1.2),
                  Expanded(
                    child: solveVideos.isEmpty
                        ? const Center(
                      child: Text(
                        "No videos available",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                        : ListView.separated(
                      itemCount: solveVideos.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final video = solveVideos[index];
                        final title = video['title'] ?? 'No Title';
                        final url = video['video_url'];

                        final videoId = YoutubePlayer.convertUrlToId(url ?? '');
                        if (url == null || videoId == null) {
                          return ListTile(
                            leading: const Icon(Icons.error, color: Colors.red),
                            title: Text(title),
                            subtitle: const Text("Invalid or missing video URL"),
                          );
                        }

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: IconButton(
                            icon: const Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 36),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => YoutubePlayerPage(videoId: videoId),
                              ));
                            },
                            tooltip: "Play Video",
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
          selectedAnswers.clear();
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

  // Widget buildImageContent(String htmlString) {
  //   final RegExp exp = RegExp(r'<img[^>]+src="([^">]+)"');
  //   final match = exp.firstMatch(htmlString);
  //   final imageUrl = match?.group(1);
  //
  //   if (imageUrl == null) {
  //     return const Text('Image not found');
  //   }
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       Center(
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(12),
  //           child: Image.network(
  //             imageUrl,
  //             fit: BoxFit.contain,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 10),
  //     ],
  //   );
  // }

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
            child: ImageWithPlaceholder(imageUrl: imageUrl),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }


  Widget buildDiscussionModal() {
    if (!showDiscussionModal) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => setState(() => showDiscussionModal = false),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
        ),
        Center(
          child: Material( // ✅ Modal content inside Material
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 500,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, // ✅ Pure white background
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.white, // 🔍 Test color to see background issue
                          child: const Text(
                            "Discussion",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              backgroundColor: Colors.transparent, // ✅ no yellow
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => showDiscussionModal = false),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(height: 1, thickness: 1, color: Colors.black12),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Html(
                        data: discussionContent,
                        style: {
                          "*": Style(
                            backgroundColor: Colors.transparent,
                            fontSize: FontSize.small,
                            color: Colors.black,
                          ),
                          "p": Style(
                            fontSize: FontSize.small,
                            backgroundColor: Colors.transparent,
                            margin: Margins.only(bottom: 6),
                          ),
                          "span": Style(backgroundColor: Colors.transparent),
                          "mark": Style(backgroundColor: Colors.transparent),
                          "table": Style(backgroundColor: Colors.transparent),
                          "td": Style(backgroundColor: Colors.transparent),
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppLayout(
          title: '${widget.ebookName} Questions',
          body: isLoading
              ? ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: 6,
                  itemBuilder: (context, index) => buildSkeletonCard(),
                )
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
                      const SizedBox(height: 5),
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
                            buildActionButton(
                              label: "Discussion",
                              onTap: () =>
                                  fetchDiscussionContent(content.id.toString()),
                              isActive: false,
                            ),
                          if (content.hasSolveVideo)
                            buildActionButton(
                              label: "Video",
                              onTap: () =>
                                  fetchSolveVideos(content.id.toString()),
                              isActive: false,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        buildDiscussionModal(),
        buildVideoModal(),
      ],
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

class YoutubePlayerPage extends StatelessWidget {
  final String videoId;
  const YoutubePlayerPage({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    final YoutubePlayerController controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Solve Video")),
      body: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
      ),
    );
  }
}

class ImageWithPlaceholder extends StatefulWidget {
  final String imageUrl;

  const ImageWithPlaceholder({super.key, required this.imageUrl});

  @override
  State<ImageWithPlaceholder> createState() => _ImageWithPlaceholderState();
}

class _ImageWithPlaceholderState extends State<ImageWithPlaceholder> {
  bool _isLoaded = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (!_isLoaded)
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 200, // আপনি চাইলে উচ্চতা পরিবর্তন করতে পারেন
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        Image.network(
          widget.imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _isLoaded = true);
                }
              });
              return child;
            }
            return Container(); // লোডিং চলাকালীন খালি কন্টেইনার
          },
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.broken_image,
            size: 100,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

