import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/components/shimmer_ebook_detail_loader.dart';
import 'package:ebook_project/screens/ebook_subjects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebook_project/utils/token_store.dart';

class EbookDetailPage extends StatefulWidget {
  final String ebookId;
  final Map<String, dynamic> ebook; // Pass the ebook data as a parameter

  const EbookDetailPage(
      {super.key, required this.ebookId, required this.ebook});

  @override
  _EbookDetailPageState createState() => _EbookDetailPageState();
}

class _EbookDetailPageState extends State<EbookDetailPage> {
  Map<String, dynamic> ebookDetail = {};
  bool isLoading = true;
  bool isError = false;
  bool? practiceAvailable;
  bool isPracticeStatusLoading = true;
  String selectedTab = 'features'; // Tab selection

  @override
  void initState() {
    super.initState();
    _maybeStoreTokenFromLink();
    fetchEbookDetails();
    _checkPracticeAvailability();
  }

  Future<void> _maybeStoreTokenFromLink() async {
    final rawLink = widget.ebook['button']?['link']?.toString();
    final fallbackLink = widget.ebook['image']?.toString();
    final token = TokenStore.extractTokenFromUrl(rawLink) ??
        TokenStore.extractTokenFromUrl(fallbackLink);
    if (token == null || token.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await TokenStore.savePracticeToken(token);
  }

  Future<void> fetchEbookDetails() async {
    ApiService apiService = ApiService();
    try {
      final data =
          await apiService.fetchEbookData("/v1/ebooks/${widget.ebookId}");
      setState(() {
        ebookDetail = data['eBook'];
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching ebook details: $error");
    }
  }

  Future<void> _checkPracticeAvailability() async {
    final apiService = ApiService();
    try {
      final endpoint =
          await TokenStore.attachPracticeToken("/v1/ebooks/${widget.ebookId}/practice-access");
      final data = await apiService.fetchEbookData(endpoint);
      final available = data['practice_questions_available'] == true;
      if (!mounted) return;
      setState(() {
        practiceAvailable = available;
        isPracticeStatusLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        practiceAvailable = null;
        isPracticeStatusLoading = false;
      });
      print("Error fetching practice availability: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpired = widget.ebook['isExpired'] == true;
    final dynamic ebookStatus = widget.ebook['status'];
    final String? normalizedStatus = ebookStatus?.toString().trim().toLowerCase();
    final bool isActive = normalizedStatus == 'active' ||
        ebookStatus == 1 ||
        ebookStatus == '1' ||
        ebookStatus == true;
    final bool canShowPracticeButton =
        practiceAvailable == true &&  isExpired;
    return AppLayout(
      // title: "Ebook Details",
      title: "${widget.ebook['name']} Details",
      body: isLoading
          ?  const ShimmerEbookDetailLoader()
          : isError
              ? Center(child: Text('Failed to load ebook details'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Ebook Title and Details
                        Text(
                          'Welcome to Banglamed E-Book',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium, // Updated text style
                        ),
                        const SizedBox(height: 8),

                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(
                                    0xFFF3F4F6), // Background color for the box
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corners
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize
                                    .min, // Ensures the column only takes the space needed
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: ((ebookDetail['specifications'] as List?)
                                            ?? [])
                                        .map<Widget>((spec) {
                                  if (spec == null || spec is! Map) {
                                    return const SizedBox.shrink();
                                  }
                                  return _buildRow(spec['title'], spec['value']);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        if (!isExpired)
                          ElevatedButton(
                            onPressed: () => _openSubjects(practice: false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF0c4a6e), // Normal color #0c4a6e
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ).copyWith(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return const Color.fromARGB(
                                            255, 8, 140, 216)
                                        .withOpacity(0.5);
                                  } else if (states
                                      .contains(MaterialState.hovered)) {
                                    return const Color.fromARGB(
                                            255, 8, 140, 216)
                                        .withOpacity(0.8);
                                  }
                                  return const Color.fromARGB(255, 12, 128, 196);
                                },
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons
                                      .solidHandPointRight,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Go to Subjects',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        if (isExpired)
                          const Padding(
                            padding: EdgeInsets.only(top: 6.0),
                            child: Text(
                              'Your reading access is expired.',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (canShowPracticeButton) ...[
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _openSubjects(practice: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0f172a),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  FontAwesomeIcons.questionCircle,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Practice Questions',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 16),
                        // Features and Instructions Tabs
                        ebookDetail['image'] == null ||
                                ebookDetail['image'] == ""
                            ? Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.book,
                                    color: Colors.grey,
                                    size: 80,
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 400,
                                child: Image.network(
                                  ebookDetail['image'],
                                  fit: BoxFit.contain,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                        ),
                                      );
                                    }
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 80,
                                      ),
                                    );
                                  },
                                ),
                                // child: Image(
                                //   image: AssetImage('assets/productDemo.jpg'),

                                // )
                              ),

                        // Button to go to subjects
                        DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              TabBar(
                                onTap: (index) {
                                  setState(() {
                                    selectedTab = index == 0
                                        ? 'features'
                                        : 'instructions';
                                  });
                                },
                                tabs: [
                                  Tab(text: 'Features'),
                                  Tab(text: 'Instructions'),
                                ],
                              ),
                              SizedBox(
                                height: 250,
                                child: TabBarView(
                                  children: [
                                    // Features Tab
                                    ebookDetail['features'] != null &&
                                            ebookDetail['features'].isNotEmpty
                                        ? SingleChildScrollView(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Html(
                                                  data:
                                                      ebookDetail['features']),
                                            ),
                                          )
                                        : Center(
                                            child:
                                                Text('No features available')),
                                    // Instructions Tab
                                    ebookDetail['instructions'] != null &&
                                            ebookDetail['instructions']
                                                .isNotEmpty
                                        ? SingleChildScrollView(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Html(
                                                  data: ebookDetail[
                                                      'instructions']),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                                'No instructions available')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  )),
    );
  }

  Future<void> _openSubjects({required bool practice}) async {
    await _maybeStoreTokenFromLink();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EbookSubjectsPage(
          ebookId: ebookDetail['id'].toString(),
          ebookName: widget.ebook['name'].toString(),
          practice: practice,
        ),
      ),
    );
  }

  Widget _buildRow(dynamic label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
