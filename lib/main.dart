import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/api/routes.dart';
import 'package:ebook_project/components/custom_drawer.dart';
import 'package:ebook_project/components/ebook_card.dart';
import 'package:ebook_project/models/ebook.dart';
import 'package:flutter/material.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0EA5E9)),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'My Ebooks'),
      initialRoute: '/', // Define the initial route
      routes: {
        '/': (context) => MyHomePage(title: 'My Ebooks'), // Home page route
        '/home': (context) => MyHomePage(title: 'My Ebooks'),
      },
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

  Future<void> fetchEbooks() async {
    ApiService apiService = ApiService();
    try {
      final data = await apiService.fetchEbookData('/v1/ebooks');
      setState(() {
        ebooks = (data['0'] as List).map((e) => Ebook.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching ebooks: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
          ? const Center(child: CircularProgressIndicator())
          // : GridView.builder(
          //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //       crossAxisCount: 2, // Two cards per row
          //       crossAxisSpacing: 8.0,
          //       mainAxisSpacing: 8.0,
          //       childAspectRatio: 1.2, // Adjust based on design
          //     ),
          //     itemCount: ebooks.length,
          //     padding: const EdgeInsets.all(8.0),
          //     itemBuilder: (context, index) {
          //       return EbookCard(ebook: ebooks[index]);
          //     },
          //   ),
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: ebooks.length,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  return EbookCard(ebook: ebooks[index]);
                },
              ),
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
