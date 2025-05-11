import 'package:ebook_project/ebook_detail.dart';
import 'package:ebook_project/models/ebook.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EbookCard extends StatelessWidget {
  final Ebook ebook;

  const EbookCard({required this.ebook, super.key});

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
        return Colors.blue;
      case 'Renew Softcopy':
        return Colors.red;
      case 'Continue':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    color: ebook.isExpired
                        ? Colors.red
                          : ebook.status == 1
                            ? Colors.green
                              : Colors.orange,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                      ebook.isExpired
                          ? 'Expired'
                            : ebook.status == 1
                              ? 'Active'
                                : 'Pending',
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
                      backgroundColor: _getButtonColor(ebook.button!.value),
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
                                  ebookId: ebook.id
                                      .toString(), // Pass the required ebookId as a String
                                ),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duration:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    ebook.validity ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ending:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    ebook.ending ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
