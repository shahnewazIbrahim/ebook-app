import 'package:ebook_project/components/under_maintanance_snackbar.dart';
import 'package:ebook_project/screens/ebook_detail.dart';
import 'package:ebook_project/models/ebook.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EbookCard extends StatelessWidget {
  final Ebook ebook;

  const EbookCard({required this.ebook, super.key});

  // Function to open the URL in the browser
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  LinearGradient _getButtonGradient(String? buttonValue) {
    switch (buttonValue) {
      case 'Read E-Book':
        return LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]);
      case 'Renew Softcopy':
        return LinearGradient(colors: [Colors.red, Colors.redAccent]);
      case 'Continue':
        return LinearGradient(colors: [Colors.purple, Colors.purpleAccent]);
      default:
        return LinearGradient(colors: [Colors.grey, Colors.grey]);
    }
  }

  Color _getTextColor(String? buttonValue) {
    if (buttonValue == 'Continue') {
      return Colors.white;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                  Container(
                    decoration: BoxDecoration(
                      gradient: _getButtonGradient(ebook.button!.value),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        ebook.button!.value == 'Read E-Book'
                            ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EbookDetailPage(
                              ebook: ebook.toJson(),
                              ebookId: ebook.id.toString(),
                            ),
                          ),
                        )
                            : 
                        // _launchURL(ebook.button!.link)
                        showUnderMaintenanceSnackbar()
                        ;
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 10.0),
                        child: Text(
                          ebook.button!.value == 'Renew Softcopy'
                              ? 'Renew'
                              : ebook.button!.value == 'Read E-Book'
                              ? 'Read'
                              : ebook.button!.value ?? 'Link',
                          style: TextStyle(
                            color: _getTextColor(ebook.button!.value),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
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
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
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
                    style: const TextStyle(
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
