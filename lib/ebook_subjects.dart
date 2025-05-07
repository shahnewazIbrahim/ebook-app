import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/custom_drawer.dart';
import 'package:flutter/material.dart';

class EbookSubjectsPage extends StatefulWidget {
  final String ebookId;

  const EbookSubjectsPage(
      {super.key, required this.ebookId, required Map<String, dynamic> ebook});

  @override
  _EbookSubjectsState createState() => _EbookSubjectsState();
}

class _EbookSubjectsState extends State<EbookSubjectsPage> {
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
          title: Text('Ebook Subjects'),
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
        body: Center(
          child: Text(
            'Subject page e aschi',
            style: TextStyle(
              fontSize: 22,
            ),
          ),
        ));
  }
}
