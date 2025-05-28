import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/models/ebook_content.dart';
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
          child: Material( // ✅ Material wrapper added
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 400,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text("Solve Videos",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        onPressed: () => setState(() => showVideoModal = false),
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: solveVideos.length,
                      itemBuilder: (context, index) {
                        final video = solveVideos[index];
                        final title = video['title'] ?? 'No Title';
                        final url = video['video_url'];

                        if (url == null || YoutubePlayer.convertUrlToId(url) == null) {
                          return ListTile(
                            title: Text(title),
                            subtitle: const Text("Invalid or missing video URL"),
                            trailing: const Icon(Icons.error, color: Colors.red),
                          );
                        }

                        final videoId = YoutubePlayer.convertUrlToId(url)!;

                        return ListTile(
                          title: Text(title),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_circle_fill, color: Colors.red),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) =>
                                      YoutubePlayerPage(videoId: videoId)));
                            },
                          ),
                        );
                      },
                    ),
                  )
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
