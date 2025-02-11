import 'dart:convert'; // For JSON decoding

import 'package:ebook_project/api/routes.dart';
import 'package:ebook_project/ebook_detail.dart';
import 'package:ebook_project/models/ebook.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For API requests
import 'package:url_launcher/url_launcher.dart'; // For opening URLs

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Ebooks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0EA5E9)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My Ebooks'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Ebook> ebooks = []; // Change to List<dynamic>
  bool isLoading = true;

  // API Endpoint
  // final String apiUrl = "http://127.0.0.1:8000/api/v1/ebooks";
  var apiUrl = getFullUrl('/v1/ebooks');
  // Replace with your API URL

  @override
  void initState() {
    super.initState();
    fetchEbooks();
  }

  Future<List<Ebook>> fetchEbooks() async {
    try {
      var headers = {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer 24481|pHCYJ0aZvP04Js9SM076EzrGsUmqdTpZnFRcOvWE",
      };

      final response = await http.get(
        apiUrl,
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Success - Parse the JSON response
        final data = json.decode(response.body);
        setState(() {
          ebooks = (data['0'] as List).map((e) => Ebook.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        // Handle error responses
        print(
            "Failed to fetch ebooks: ${response.statusCode}, ${response.body}");
      }
    } catch (error) {
      // Handle any exceptions
      print("Error fetching ebooks: $error");
    }
    return ebooks;
  }

  // Function to open the URL in the browser
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    // Check if the URL can be launched
    if (await canLaunchUrl(uri)) {
      // Launch the URL
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Color _getButtonColor(String? buttonValue) {
    switch (buttonValue) {
      case 'Read E-Book':
        return Colors.blue; // Blue for 'Read E-Book'
      case 'Renew Softcopy':
        return Colors.red; // Red for 'Renew Softcopy'
      case 'Continue':
        return Colors.yellow; // Yellow for 'Continue'
      default:
        return Colors.grey; // Default color if no match
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'My Ebooks',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                // Navigate to the home page
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                // Navigate to the settings page
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('User'),
              onTap: () {
                // Navigate to the user page
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two cards per row
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.2, // Adjust based on design
              ),
              itemCount: ebooks.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final ebook = ebooks[index];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ebook.image.isNotEmpty
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(ebook.image),
                                  )
                                : CircleAvatar(
                                    radius: 20,
                                    child: Text(
                                      ebook.name[0],
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                ebook.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: ebook.status == 'Active'
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                ebook.status == 'Active' ? 'Active' : 'Expired',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (ebook.button != null && ebook.button!.status)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getButtonColor(
                                      ebook.button!.value), // Conditional color
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 8.0),
                                ),
                                onPressed: () {
                                  ebook.button!.value == 'Read E-Book'
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EbookDetailPage(
                                              ebook: ebook.toJson(),
                                            ),
                                            settings: RouteSettings(
                                                name: '/my-ebooks/${ebook.id}'),
                                          ),
                                        )
                                      : _launchURL(ebook.button!.link);
                                },
                                child: Text(
                                  ebook.button!.value == 'Renew Softcopy'
                                      ? 'Renew'
                                      : ebook.button!.value == 'Read E-Book'
                                          ? 'Read'
                                          : ebook.button!.value ?? 'Link',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Duration: ${ebook.validity}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          'Ending: ${ebook.ending}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Theme.of(context).useMaterial3
          ? NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (int index) {
                // Handle navigation based on the selected index
                switch (index) {
                  case 0:
                    // Navigate to the home page
                    break;
                  case 1:
                    // Navigate to the ebooks page
                    break;
                  case 2:
                    // Navigate to the settings page
                    break;
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.book),
                  label: 'Ebooks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'User',
                ),
              ],
            )
          : null,
    );
  }
}
