// lib/components/ebook_grid.dart
import 'package:ebook_project/components/under_maintanance_snackbar.dart';
import 'package:ebook_project/models/ebook.dart';
import 'package:ebook_project/screens/ebook_detail.dart';
import 'package:ebook_project/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EbookGrid extends StatelessWidget {
  final List<Ebook> ebooks;
  final bool isLoading;

  const EbookGrid({
    super.key,
    required this.ebooks,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cross = _gridCountForWidth(w);
        final aspect = _aspectForWidth(w);

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspect,
          ),
          itemCount: ebooks.length,
          itemBuilder: (_, i) => _EbookGridCard(ebook: ebooks[i], tileIndex: i),
        );
      },
    );
  }

  int _gridCountForWidth(double w) {
    if (w >= 1280) return 5;
    if (w >= 1024) return 4;
    if (w >= 768) return 3;
    return 2;
  }

  double _aspectForWidth(double w) {
    if (w >= 1280) return 0.78;
    if (w >= 1024) return 0.80;
    if (w >= 768)  return 0.72;
    return 0.64; // মোবাইলে লম্বা কার্ড
  }
}

class _EbookGridCard extends StatelessWidget {
  final Ebook ebook;
  final int tileIndex;
  const _EbookGridCard({required this.ebook, required this.tileIndex});

  bool get _isActive {
    final s = ebook.status;
    return s == 1 || s == '1' || s == true || s == 'Active';
  }
  bool get _isExpired => ebook.isExpired == true;

  String get _statusText =>
      _isExpired ? 'Expired' : (_isActive ? 'Active' : 'Pending');

  Color get _statusColor =>
      _isExpired ? Colors.red : (_isActive ? Colors.green : Colors.orange);

  bool get _hasButton => ebook.button?.status == true;

  bool get _hasRenewAction {
    final v = (ebook.button?.value ?? '').toLowerCase();
    return v.contains('renew');
  }

  Future<void> _goDetails(BuildContext context) async {
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

  Future<void> _goRenewOrExternal() async {
    showUnderMaintenanceSnackbar();
  }

  Future<void> _onTap(BuildContext context) async {
    if (_isExpired) {
      if (_hasButton && _hasRenewAction) {
        await _goRenewOrExternal();
      } else {
        Get.snackbar('Expired', 'এই ই-বুকটির মেয়াদ শেষ হয়েছে।',
            snackPosition: SnackPosition.BOTTOM);
      }
      return;
    }
    await _goDetails(context);
  }

  @override
  Widget build(BuildContext context) {
    final tint = AppColors.cardTintByIndex(tileIndex);

    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _onTap(context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(
            builder: (context, c) {
              final dense = c.maxHeight < 260;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== Cover (flexible) =====
                  // Expanded(
                  //   child: Stack(
                  //     fit: StackFit.expand,
                  //     children: [
                  //       ClipRRect(
                  //         borderRadius: BorderRadius.circular(12),
                  //         child: (ebook.image.isNotEmpty)
                  //             ? Image.network(ebook.image, fit: BoxFit.cover)
                  //             : Container(
                  //           decoration: BoxDecoration(
                  //             color: tint,
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //           child: Center(
                  //             child: Text(
                  //               (ebook.name.isNotEmpty
                  //                   ? ebook.name[0]
                  //                   : '?')
                  //                   .toUpperCase(),
                  //               style: const TextStyle(
                  //                 fontWeight: FontWeight.w800,
                  //                 fontSize: 28,
                  //                 color: AppColors.textPrimary,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       Positioned(
                  //         top: 8,
                  //         left: 8,
                  //         child: Container(
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 8, vertical: 4),
                  //           decoration: BoxDecoration(
                  //             color: _statusColor,
                  //             borderRadius: BorderRadius.circular(8),
                  //           ),
                  //           child: Text(
                  //             _statusText,
                  //             style: const TextStyle(
                  //                 color: Colors.white, fontSize: 11.5),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
// ===== Cover (flexible) =====
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _CoverImage(
                            imageUrl: ebook.image,
                            fallbackUrl: 'https://banglamed.s3.ap-south-1.amazonaws.com/images/default_book.png',
                          ),
                        ),

                        // ===== Status badge (always on top) =====
                        Positioned(
                          top: 8,
                          left: 8,
                          child: IgnorePointer(
                            ignoring: true, // ট্যাপ ব্লক করবে না
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 1),  // হালকা স্ট্রোক
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000), // subtle shadow
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                _statusText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ===== Title (package-free auto-fit) =====
                  // Fixed height box; ভিতরে FittedBox scaleDown করে নেয়
                  Builder(builder: (context) {
                    final titleBoxH = dense ? 36.0 : 48.0; // 2–3 লাইনের জায়গা
                    return SizedBox(
                      height: titleBoxH,
                      width: double.infinity,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              // Grid সেলের প্রস্থেই constrain করি
                              maxWidth: c.maxWidth,
                            ),
                            child: MediaQuery(
                              // সিস্টেম text-scale বড় হলেও এখানে 1.0
                              data: MediaQuery.of(context).copyWith(
                                textScaler: const TextScaler.linear(1.0),
                              ),
                              child: Text(
                                ebook.name,
                                softWrap: true,
                                maxLines: dense ? 2 : 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16, // বেস সাইজ; FittedBox কমাবে
                                  height: 1.15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  if (!dense) ...[
                    const SizedBox(height: 6),
                    _TinyMeta(icon: Icons.timelapse_outlined, value: ebook.validity),
                    const SizedBox(height: 3),
                    _TinyMeta(icon: Icons.event_outlined, value: ebook.ending),
                  ],

                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TinyMeta extends StatelessWidget {
  final IconData icon;
  final String? value;
  const _TinyMeta({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final v = value ?? 'N/A';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            v,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String imageUrl;
  final String fallbackUrl;
  const _CoverImage({required this.imageUrl, required this.fallbackUrl});

  @override
  Widget build(BuildContext context) {
    final String cover = (imageUrl.isNotEmpty) ? imageUrl : fallbackUrl;

    return Image.network(
      cover,
      fit: BoxFit.cover,
      // লোডিং অবস্থায় হালকা প্লেসহোল্ডার
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.menu_book_outlined, size: 36, color: Colors.black38),
          ),
        );
      },
      // নেটওয়ার্ক ফেইল করলে ডিফল্ট
      errorBuilder: (context, error, stack) {
        return Image.network(
          fallbackUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, _, __) {
            // ডিফল্টও ফেইল করলে শেষ অবলম্বন
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.menu_book_outlined, size: 36, color: Colors.black38),
              ),
            );
          },
        );
      },
    );
  }
}

