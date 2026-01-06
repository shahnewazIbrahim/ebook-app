import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/screens/ebook_chapters.dart';
import 'package:ebook_project/models/ebook_subject.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ebook_project/components/shimmer_list_loader.dart';
import 'package:ebook_project/utils/token_store.dart';

class EbookSubjectsPage extends StatefulWidget {
  final String ebookId;
  final String ebookName;
  final bool practice;

  const EbookSubjectsPage({
    super.key,
    required this.ebookId,
    required this.ebookName,
    this.practice = false,
  });

  @override
  _EbookSubjectsState createState() => _EbookSubjectsState();
}

class _EbookSubjectsState extends State<EbookSubjectsPage> {
  List<EbookSubject> ebookSubjects = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchEbookSubjects();
  }

  Future<void> fetchEbookSubjects() async {
    ApiService apiService = ApiService();
    try {
      var endpoint = "/v1/ebooks/${widget.ebookId}/subjects";
      if (widget.practice) {
        endpoint += "?practice=1";
      }
      // endpoint = await TokenStore.attachPracticeToken(endpoint);
      final data = await apiService.fetchEbookData(endpoint);
      print("fetching from endpoint: $data['message']");
      setState(() {
        ebookSubjects = (data['subjects'] as List)
            .map((subjectJson) => EbookSubject.fromJson(subjectJson))
            .toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isError = true;
        isLoading = false;
      });
      print("Error fetching ebook subjects: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: '${widget.ebookName} Subjects',
      body: isLoading
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: ShimmerListLoader(),
            )
          : isError
              ? const Center(child: Text('Failed to load subjects'))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ebookSubjects.isEmpty
                      ? const Center(
                          child: Text(
                            'No Subjects Available',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: ebookSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = ebookSubjects[index];

                            if (subject.title.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return GestureDetector(
                              onTap: () {
                                if (subject.locked) {
                                  _showSubscriptionDialog(context);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EbookChaptersPage(
                                      ebookId: widget.ebookId,
                                      subjectId: subject.id.toString(),
                                      ebookName: widget.ebookName,
                                      practice: widget.practice,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFe0f2fe),
                                      Color(0xFFbae6fd)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) {
                                        return const LinearGradient(
                                          colors: [
                                            Color(0xFF0ea5e9),
                                            Color(0xFF0369a1)
                                          ],
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
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              subject.title,
                                              style: const TextStyle(
                                                fontSize: 16.5,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0f172a),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (subject.locked)
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(left: 8.0),
                                              child: Icon(
                                                Icons.lock,
                                                color: Colors.redAccent,
                                                size: 20,
                                              ),
                                            ),
                                        ],
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

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Subscription Required'),
        content: const Text(
          'This item is locked in practice mode. Please subscribe or purchase access to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamed('/choose-plan/${widget.ebookId}');
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }
}
