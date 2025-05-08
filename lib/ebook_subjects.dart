import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/custom_drawer.dart';
import 'package:ebook_project/ebook_chapters.dart';
import 'package:ebook_project/models/ebook_subject.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EbookSubjectsPage extends StatefulWidget {
  final String ebookId;

  const EbookSubjectsPage(
      {super.key,
      required this.ebookId}); // Pass the subjectId to the constructor

  @override
  _EbookSubjectsState createState() => _EbookSubjectsState();
}

class _EbookSubjectsState extends State<EbookSubjectsPage> {
  List<EbookSubject> ebookSubjects = [];
  bool isLoading = true;
  bool isError = false;
  String selectedTab = 'features'; // Tab selection

  @override
  void initState() {
    super.initState();
    fetchEbookSubjects();
  }

  Future<void> fetchEbookSubjects() async {
    ApiService apiService = ApiService();
    try {
      final data = await apiService
          .fetchEbookData("/v1/ebooks/${widget.ebookId}/subjects");
      setState(() {
        ebookSubjects = (data['subjects'] as List)
            .map((subjectJson) => EbookSubject.fromJson(subjectJson))
            .toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching ebook subjects: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Ebook Subjects'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      endDrawer: CustomDrawer(
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: ebookSubjects.length,
          padding: const EdgeInsets.all(8.0),
          itemBuilder: (context, index) {
            // Check if the title is not empty
            if (ebookSubjects[index].title.isNotEmpty) {
              return GestureDetector(
                onTap: () {
                  // Add navigation logic to the 'Chapters' screen with parameters
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EbookChaptersPage(
                        ebookId: widget
                            .ebookId, // Pass the required ebookId as a String
                        subjectId: ebookSubjects[index]
                            .id
                            .toString(), // Pass the required subjectId as a String
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
                              colors: [Colors.blue[200]!, Colors.blue[600]!],
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
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Text(
                                ebookSubjects[index].title,
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

      //  Padding(
      //   padding: const EdgeInsets.all(4.0),
      //   child: GridView.builder(
      //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //       crossAxisCount: 2, // Two cards per row
      //       crossAxisSpacing: 4.0, // Reduced horizontal spacing
      //       mainAxisSpacing: 4.0, // Reduced vertical spacing
      //       childAspectRatio: 1.2,
      //     ),
      //     itemCount: ebookSubjects.length,
      //     padding: const EdgeInsets.all(4.0),
      //     itemBuilder: (context, index) {
      //       // Check if the title is not empty
      //       if (ebookSubjects[index].title.isNotEmpty) {
      //         return GestureDetector(
      //             onTap: () {
      //               // Add navigation logic to the 'Chapters' screen with parameters
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => EbookChaptersPage(
      //                     ebookId: widget
      //                         .ebookId, // Pass the required ebookId as a String
      //                     subjectId: ebookSubjects[index]
      //                         .id
      //                         .toString(), // Pass the required subjectId as a String
      //                   ),
      //                 ),
      //               );
      //             },
      //             child: Card(
      //               color: Colors.grey[200],
      //               margin: EdgeInsets.symmetric(
      //                 vertical: 5.0,
      //                 horizontal: MediaQuery.of(context).size.width *
      //                     0.03, // Adjust horizontal margin for responsiveness
      //               ),
      //               child: Padding(
      //                 padding: EdgeInsets.all(
      //                     MediaQuery.of(context).size.width *
      //                         0.04), // Adjust padding based on screen width
      //                 child: Column(
      //                   mainAxisSize: MainAxisSize
      //                       .min, // Ensure the column takes up minimum space
      //                   mainAxisAlignment: MainAxisAlignment
      //                       .center, // Ensure the column takes up minimum space
      //                   crossAxisAlignment: CrossAxisAlignment.center,
      //                   children: [
      //                     ShaderMask(
      //                       shaderCallback: (bounds) {
      //                         return LinearGradient(
      //                           colors: [
      //                             Colors.blue[200]!,
      //                             Colors.blue[600]!
      //                           ],
      //                           begin: Alignment.topLeft,
      //                           end: Alignment.bottomRight,
      //                         ).createShader(bounds);
      //                       },
      //                       child: Icon(
      //                         FontAwesomeIcons.book,
      //                         color: Colors.white,
      //                         size: MediaQuery.of(context).size.width *
      //                             0.08, // Adjust icon size based on screen width
      //                       ),
      //                     ),
      //                     SizedBox(
      //                         width: MediaQuery.of(context).size.width *
      //                             0.04), // Adjust space between icon and text
      //                     Flexible(
      //                       child: Text(
      //                         ebookSubjects[index].title,
      //                         style: TextStyle(
      //                           fontSize: MediaQuery.of(context).size.width *
      //                               0.04, // Adjust font size based on screen width
      //                           fontWeight: FontWeight.bold,
      //                         ),
      //                         overflow: TextOverflow.ellipsis,
      //                         maxLines: 2,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ));
      //       } else {
      //         return Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             Text('No Subjects Available',
      //                 style: TextStyle(
      //                   fontSize: MediaQuery.of(context).size.width * 0.04,
      //                   fontWeight: FontWeight.bold,
      //                 ))
      //           ],
      //         ); // Skip empty titles
      //       }
      //     },
      //   ),
      // )
    );
  }
}
