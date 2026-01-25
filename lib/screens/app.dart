import 'package:ebook_project/components/ebook_grid.dart';
import 'package:ebook_project/screens/profile.dart';
import 'package:ebook_project/screens/splash.dart';
import 'package:ebook_project/theme/app_colors.dart';
import 'package:ebook_project/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_service.dart';
import '../components/app_layout.dart';
import '../components/shimmer_ebook_card_loader.dart';
import '../components/under_maintanance_snackbar.dart';
import '../models/all_ebook.dart';
import '../models/ebook.dart';
import 'ebook_detail.dart';
import 'device_verification.dart';
import 'login.dart';
import 'my_ebooks_page.dart';
import '../utils/token_store.dart';

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
        '/my-ebooks': (context) => const MyEbooksPage(),
        '/login': (context) => const LoginPage(),
        '/device-verification': (context) => const DeviceVerificationPage(),
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
  final Map<int, bool> _practiceAvailability = {};
  final Map<int, Future<bool>> _practiceFutures = {};

  @override
  void initState() {
    _checkForUpdate();
    super.initState();
    fetchEbooks();
  }

  Future<void> fetchEbooks() async {
    final apiService = ApiService();
    try {
      final data = await apiService.fetchEbookData('/v1/all-ebooks');
      final list = _normalizeEbookList(data);
      setState(() {
        ebooks = list.map((e) => AllEbook.fromJson(e).toEbook()).toList();
        isLoading = false;
        _practiceAvailability.clear();
        _practiceFutures.clear();
      });
      for (final ebook in ebooks) {
        _ensurePracticeAvailability(ebook);
      }
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

      body: isLoading
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: ShimmerEbookCardLoader(),
            )
          : _buildLoadedBody(),
    );
  }

  bool _isActive(Ebook ebook) {
    final s = ebook.status;
    return s == 1 || s == '1' || s == true || s == 'Active';
  }

  Future<void> _handleCardTap(BuildContext context, Ebook ebook) async {
    if (!ebook.isExpired && !_isActive(ebook)) {
      showUnderMaintenanceSnackbar();
      return;
    }

    final hasPractice = await _ensurePracticeAvailability(ebook);
    // if(ebook.isExpired) {
    //
    // }
    if (!hasPractice && ebook.isExpired) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Practice questions are not available for this book.'),
        ),
      );
      return;
    }
    //for debugging
    // ScaffoldMessenger.of(context).showSnackBar(
    //    SnackBar(
    //     content: Text('${ebook.isExpired}'),
    //   ),
    // );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EbookDetailPage(
          ebook: ebook.toJson(),
          ebookId: ebook.id.toString(),
        ),
        settings: RouteSettings(name: '/my-ebooks/${ebook.id}'),
      ),
    );
  }

  Widget _buildLoadedBody() {
    final pendingEbooks = ebooks.where((ebook) => !_isActive(ebook)).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDeviceVerificationCard(),
          const SizedBox(height: 12),
          if (pendingEbooks.isNotEmpty) ...[
            _buildPurchaseSection(pendingEbooks),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: EbookGrid(
              ebooks: ebooks,
              isLoading: isLoading,
              practiceAvailability: _practiceAvailability,
              onCardTap: _handleCardTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceVerificationCard() {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.verified_user, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keep this device verified',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verify on banglamed.net to keep your ebooks available here.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: _openDeviceVerification,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseSection(List<Ebook> pendingEbooks) {
    final preview = pendingEbooks.take(3).toList();
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.shopping_cart, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Grab your next ebook plan',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: _openPurchaseCatalog,
                  child: const Text('Visit store'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: preview.map((ebook) {
                return SizedBox(
                  width: 150,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => _openPurchaseLink(ebook),
                    style: OutlinedButton.styleFrom(
                      side:
                          BorderSide(color: AppColors.primary.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      ebook.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (pendingEbooks.length > preview.length)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Plus ${pendingEbooks.length - preview.length} more on the store.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openDeviceVerification() {
    Navigator.pushNamed(context, '/device-verification');
  }

  Future<void> _openPurchaseLink(Ebook ebook) async {
    await _openExternalUrl(
      'https://banglamed.net/choose-plan/${ebook.id}',
      errorMessage: 'Unable to open purchase link for ${ebook.name}.',
    );
  }

  Future<void> _openPurchaseCatalog() async {
    await _openExternalUrl('https://banglamed.net/choose-plan');
  }

  Future<void> _openExternalUrl(String url, {String? errorMessage}) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Unable to open the link.')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> _ensurePracticeAvailability(Ebook ebook) {
    if (_practiceAvailability.containsKey(ebook.id)) {
      return Future.value(_practiceAvailability[ebook.id]!);
    }
    if (_practiceFutures.containsKey(ebook.id)) {
      return _practiceFutures[ebook.id]!;
    }

    final future = _detectPracticeAvailability(ebook);

    _practiceFutures[ebook.id] = future;
    future.then((value) {
      if (!mounted) return;
      setState(() {
        _practiceAvailability[ebook.id] = value;
      });
      _practiceFutures.remove(ebook.id);
    }).catchError((_) {
      if (!mounted) return;
      setState(() {
        _practiceAvailability.remove(ebook.id);
      });
      _practiceFutures.remove(ebook.id);
    });

    return future;
  }

  Future<bool> _detectPracticeAvailability(Ebook ebook) async {
    await _ensurePracticeToken(ebook);
    final apiService = ApiService();
    try {
      final endpoint = await TokenStore.attachPracticeToken(
          "/v1/ebooks/${ebook.id}/practice-access");
      final data = await apiService.fetchEbookData(endpoint);
      return (data['practice_questions_available'] == true);
    } catch (_) {
      return false;
    }
  }

  Future<void> _ensurePracticeToken(Ebook ebook) async {
    final existing = await TokenStore.practiceToken();
    if (existing != null && existing.isNotEmpty) return;
    final token = TokenStore.extractTokenFromUrl(ebook.button?.link);
    if (token == null || token.isEmpty) return;
    await TokenStore.savePracticeToken(token);
  }

  List<Map<String, dynamic>> _normalizeEbookList(Map<String, dynamic> data) {
    final raw = data['ebooks'] ?? data['0'] ?? data['data'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }
}
