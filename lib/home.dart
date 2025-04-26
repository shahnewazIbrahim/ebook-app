import 'package:ebook_project/ebook_detail.dart';
import 'package:ebook_project/models/ebook.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeComponent extends StatelessWidget {
  final List<Ebook> ebooks;
  final bool isLoading;

  const HomeComponent({
    Key? key,
    required this.ebooks,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
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
                                          builder: (context) => EbookDetailPage(
                                            ebook: ebook.toJson(),
                                            ebookId: ebook.id.toString(), // Pass the required ebookId as a String
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
          );
  }

  // Function to get button color based on button value
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
}
