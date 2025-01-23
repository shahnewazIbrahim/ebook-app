import 'dart:convert'; // For JSON decoding

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EbookDetailPage extends StatefulWidget {
  final Map<String, dynamic> ebook;

  const EbookDetailPage({required this.ebook, Key? key}) : super(key: key);

  @override
  _EbookDetailPageState createState() => _EbookDetailPageState();
}

class _EbookDetailPageState extends State<EbookDetailPage> {
  Map<String, dynamic> ebookDetail = {}; // Initialize as an empty map
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEbookDetails();
  }

  Future<void> fetchEbookDetails() async {
    try {
      var headers = {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer 24481|pHCYJ0aZvP04Js9SM076EzrGsUmqdTpZnFRcOvWE",
      };

      final String apiUrl =
          "http://127.0.0.1:8000/api/v1/ebooks/${widget.ebook['id']}";

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Success - Parse the JSON response
        final data = json.decode(response.body);
        setState(() {
          ebookDetail = data['eBook']; // Assign the data to ebookDetail
          isLoading = false;
        });
      } else {
        print(
            "Failed to fetch ebooks: ${response.statusCode}, ${response.body}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching ebooks: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ebook['name']),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: widget.ebook['image'] != null &&
                            widget.ebook['image'].isNotEmpty
                        ? Image.network(
                            widget.ebook['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported,
                                  size: 100);
                            },
                          )
                        : const Icon(Icons.image, size: 100),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome to Banglamed E-Book",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16.0),
                        Text("Book: ${ebookDetail['title'] ?? 'N/A'}"),
                        Text("Author: ${ebookDetail['author'] ?? 'N/A'}"),
                        Text("Publisher: ${ebookDetail['publisher'] ?? 'N/A'}"),
                        Text("ISBN: ${ebookDetail['isbn'] ?? 'N/A'}"),
                        Text("Edition: ${ebookDetail['edition'] ?? 'N/A'}"),
                        Text(
                            "Suitable for: ${ebookDetail['suitable_for'] ?? 'N/A'}"),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Define your logic here (e.g., open subjects or continue reading)
                          },
                          icon: const Icon(Icons.menu_book),
                          label: const Text("Go to Subjects"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
