import 'package:ebook_project/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class EbookDetailPage extends StatefulWidget {
  final String ebookId;

  const EbookDetailPage(
      {Key? key, required this.ebookId, required Map<String, dynamic> ebook})
      : super(key: key);

  @override
  _EbookDetailPageState createState() => _EbookDetailPageState();
}

class _EbookDetailPageState extends State<EbookDetailPage> {
  Map<String, dynamic> ebookDetail = {};
  bool isLoading = true;
  bool isError = false;
  String selectedTab = 'features'; // Tab selection

  @override
  void initState() {
    super.initState();
    fetchEbookDetails();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ebook Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
              ? Center(child: Text('Failed to load ebook details'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      const SizedBox(height: 16),
                      ebookDetail['image'] == null || ebookDetail['image'] == ""
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
                              height: 200,
                              child: Image.network(
                                ebookDetail['image'],
                                fit: BoxFit.cover,
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
                            ),
                      Text(
                        'Book: ${ebookDetail['title'] ?? 'N/A'}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium, // Updated text style
                      ),
                      Text(ebookDetail['image']),
                      Text('Author: ${ebookDetail['author'] ?? 'N/A'}'),
                      Text('Publisher: ${ebookDetail['publisher'] ?? 'N/A'}'),
                      Text('ISBN: ${ebookDetail['isbn'] ?? 'N/A'}'),
                      Text('Edition: ${ebookDetail['edition'] ?? 'N/A'}'),
                      Text('Suitable for: ${ebookDetail['suitable'] ?? 'N/A'}'),

                      // Features and Instructions Tabs
                      DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              onTap: (index) {
                                setState(() {
                                  selectedTab =
                                      index == 0 ? 'features' : 'instructions';
                                });
                              },
                              tabs: [
                                Tab(text: 'Features'),
                                Tab(text: 'Instructions'),
                              ],
                            ),
                            Container(
                              height: 300,
                              child: TabBarView(
                                children: [
                                  // Features Tab
                                  ebookDetail['features'] != null &&
                                          ebookDetail['features'].isNotEmpty
                                      ? SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Html(
                                                data: ebookDetail['features']),
                                          ),
                                        )
                                      : Center(
                                          child: Text('No features available')),
                                  // Instructions Tab
                                  ebookDetail['instructions'] != null &&
                                          ebookDetail['instructions'].isNotEmpty
                                      ? SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
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

                      // Button to go to subjects
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to subjects (You need to implement the Subjects screen)
                          Navigator.pushNamed(context, '/subjects',
                              arguments: ebookDetail['id']);
                        },
                        child: Text('Go to Subjects'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
