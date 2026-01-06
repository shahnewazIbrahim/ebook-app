import 'package:ebook_project/components/ebook_grid.dart';
import 'package:ebook_project/screens/profile.dart';
import 'package:ebook_project/screens/splash.dart';
import 'package:ebook_project/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:in_app_update/in_app_update.dart';

import '../api/api_service.dart';
import '../api/routes.dart';
import '../components/app_layout.dart';
import '../components/ebook_card.dart';
import '../components/shimmer_ebook_card_loader.dart';
import 'login.dart';
import '../models/ebook.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Ebooks',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0EA5E9)),
      //   useMaterial3: true,
      // ),
      initialRoute: initialRoute,
      // routes: {
      //   '/': (context) => MyHomePage(title: 'My Ebooks'),
      //   '/login': (context) => LoginPage(),
      //   '/profile': (context) => ProfilePage(),
      // },
      routes: {
        '/splash': (context) => const SplashPage(),
        '/': (context) => const MyHomePage(title: 'My Ebooks'),
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
      },

    );
  }
}

// Method to check for update
// Future<void> _checkForUpdate() async {
//   // Check for available update
//
//   InAppUpdate.checkForUpdate().then((info) {
//     if (info.updateAvailability == UpdateAvailability.updateAvailable) {
//       // If update is available, start the update flow
//       _performUpdate();
//     }
//   });
// }
//
// // Method to perform update
// Future<void> _performUpdate() async {
//   InAppUpdate.performImmediateUpdate().catchError((e) {
//     print("Update failed: $e");
//   });
// }

Future<void> _checkForUpdate() async {
  try {
    final info = await InAppUpdate.checkForUpdate();

    if (info.updateAvailability == UpdateAvailability.updateAvailable &&
        info.immediateUpdateAllowed) {
      await _performUpdate();
    }
  } catch (e) {
    // Emulator / dev mode এ এখানে আসবে
    debugPrint('In-app update skipped: $e');
  }
}

Future<void> _performUpdate() async {
  try {
    await InAppUpdate.performImmediateUpdate();
  } catch (e) {
    debugPrint('Update failed: $e');
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
    _checkForUpdate();
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
      // body: isLoading
      //     ? const Padding(
      //         padding: EdgeInsets.all(8.0),
      //         child: ShimmerEbookCardLoader(),
      //       )
      //     : Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: ListView.builder(
      //           itemCount: ebooks.length,
      //           padding: const EdgeInsets.all(8.0),
      //           itemBuilder: (context, index) {
      //             return EbookCard(ebook: ebooks[index]);
      //           },
      //         ),
      //       ),

      body:  isLoading
            ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: ShimmerEbookCardLoader(),
            )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: EbookGrid(
          ebooks: ebooks,
          isLoading: isLoading,
        ),
      ),
    );
  }
}
