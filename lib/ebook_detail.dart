import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/custom_drawer.dart';
import 'package:ebook_project/ebook_subjects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EbookDetailPage extends StatefulWidget {
  final String ebookId;

  const EbookDetailPage(
      {super.key, required this.ebookId, required Map<String, dynamic> ebook});

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Ebook Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Go back to the previous screen
            },
          ),
        ],
      ),
      drawer: CustomDrawer(
        title: 'My Ebooks',
        onHomeTap: () {
          // Handle navigation to the home page
          Navigator.pushNamed(context, '/home');
        },
        onSettingsTap: () {
          // Handle navigation to the settings page
          Navigator.pushNamed(context, '/settings');
        },
        onUserTap: () {
          // Handle navigation to the user page
          Navigator.pushNamed(context, '/user');
        },
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                        const SizedBox(height: 16),

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
                                children: ebookDetail['specifications']
                                    .map<Widget>((spec) {
                                  return _buildRow(
                                      spec['title'], spec['value']);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        ElevatedButton(
                          onPressed: () {
                            // Navigate to subjects (You need to implement the Subjects screen)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EbookSubjectsPage(
                                  ebookId: ebookDetail['id']
                                      .toString(), // Pass the required ebookId as a String
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Color(0xFF0c4a6e), // Normal color #0c4a6e
                            padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12), // Optional padding adjustment
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                            ),
                          ).copyWith(
                            // Handle hover and pressed state colors
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Color.fromARGB(255, 8, 140, 216)
                                    .withOpacity(
                                        0.5); // 50% opacity when pressed
                              } else if (states
                                  .contains(MaterialState.hovered)) {
                                return Color.fromARGB(255, 8, 140, 216)
                                    .withOpacity(
                                        0.8); // 20% opacity when hovered
                              }
                              return Color.fromARGB(
                                  255, 12, 128, 196); // Default color
                            }),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons
                                    .solidHandPointRight, // This is a hand icon from font-awesome
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Go to Subjects',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),

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
