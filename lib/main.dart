import 'package:ebook_project/components/shimmer_ebook_card_loader.dart';
import 'package:ebook_project/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/api/routes.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/components/ebook_card.dart';
import 'package:ebook_project/login.dart';
import 'package:ebook_project/models/ebook.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  runApp(MyApp(initialRoute: token == null ? '/login' : '/'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Ebooks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0EA5E9)),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => MyHomePage(title: 'My Ebooks'),
        '/home': (context) => MyHomePage(title: 'My Ebooks'),
        '/login': (context) => LoginPage(),
        '/profile': (context) => ProfilePage(),
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
  List<Ebook> ebooks = [];
  bool isLoading = true;
  var apiUrl = getFullUrl('/v1/ebooks');

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
    return AppLayout(
      title: widget.title,
      body: isLoading
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: ShimmerEbookCardLoader(),
            )
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
    );
  }
}
