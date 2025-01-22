import 'dart:convert'; // For JSON decoding

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For API requests
import 'package:url_launcher/url_launcher.dart'; // For opening URLs

void main() {
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
  List<dynamic> ebooks = []; // Change to List<dynamic>
  bool isLoading = true;

  // API Endpoint
  final String apiUrl = "http://127.0.0.1:8000/api/v1/ebooks";
  // Replace with your API URL

  @override
  void initState() {
    super.initState();
    fetchEbooks();
  }

  Future<void> fetchEbooks() async {
    try {
      var headers = {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer 24481|pHCYJ0aZvP04Js9SM076EzrGsUmqdTpZnFRcOvWE",
      };

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Success - Parse the JSON response
        final data = json.decode(response.body);
        setState(() {
          ebooks = data['0']; // Access the ebook list
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
    if (buttonValue == 'Read E-Book') {
      return Colors.blue; // Blue for 'Read E-Book'
    } else if (buttonValue == 'Renew Softcopy') {
      return Colors.red; // Red for 'Renew Softcopy'
    } else if (buttonValue == 'Continue') {
      return Colors.yellow; // Yellow for 'Continue'
    } else {
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ebooks.length,
              itemBuilder: (context, index) {
                final ebook = ebooks[index];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: ebook['image'] != null && ebook['image'].isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                                ebook['image']), // Load image from URL
                          )
                        : CircleAvatar(
                            child: Text(ebook['name'][
                                0]), // Fallback to the first letter if no image
                          ),

                    title: Text(ebook['name']),
                    // subtitle: Text('Valid until: ${ebook['ending']}'),
                    trailing: ebook['button'] != null &&
                            ebook['button']['status'] == true
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getButtonColor(ebook['button']
                                  ['value']), // Set the color conditionally
                              foregroundColor:
                                  ebook['button']['value'] == 'Continue'
                                      ? Colors.black
                                      : Colors.white,
                            ),
                            onPressed: () {
                              _launchURL(ebook['button']
                                  ['link']); // Open the link when clicked
                            },
                            child: Text((ebook['button']['value'] ==
                                        'Renew Softcopy'
                                    ? 'Renew'
                                    : (ebook['button']['value'] == 'Read E-Book'
                                        ? 'Read'
                                        : ebook['button']['value'])) ??
                                'Link'), // Fallback if 'value' is null
                          )
                        : Container(), // Show nothing if condition is not met
                    // Show nothing if condition is not met
                    // Return an empty container if status is false or button is null

                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: ${ebook['name']}')),
                      );
                    },
                    // Add the button as an ElevatedButton
                    isThreeLine: true, // Allow 3 lines in the ListTile
                    contentPadding: EdgeInsets.all(16),
                    subtitle: Text('Valid until: ${ebook['ending']}'),
                  ),
                );
              },
            ),
    );
  }
}
