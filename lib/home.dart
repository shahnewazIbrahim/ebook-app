import 'package:ebook_project/ebook_detail.dart';
import 'package:ebook_project/models/ebook.dart';
import 'package:ebook_project/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeComponent extends StatelessWidget {
  final List<Ebook> ebooks;
  final bool isLoading;

  const HomeComponent({
    super.key,
    required this.ebooks,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossCount = _gridCountForWidth(width);
        final aspect = _aspectForWidth(width);

        return GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: aspect,
          ),
          itemCount: ebooks.length,
          itemBuilder: (context, index) {
            final ebook = ebooks[index];

            return _EbookCard(
              ebook: ebook,
              tileIndex: index,
              onPrimary: () {
                // Read → details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EbookDetailPage(
                      ebook: ebook.toJson(),
                      ebookId: ebook.id.toString(),
                    ),
                    settings: RouteSettings(name: '/my-ebooks/${ebook.id}'),
                  ),
                );
              },
              onSecondary: () {
                // Open external link (Renew/Continue)
                if (ebook.button?.link != null) {
                  _launchURL(ebook.button!.link);
                }
              },
            );
          },
        );
      },
    );
  }

  // --- Responsive helpers ---
  int _gridCountForWidth(double w) {
    if (w >= 1280) return 5;
    if (w >= 1024) return 4;
    if (w >= 768) return 3;
    return 2;
  }

  double _aspectForWidth(double w) {
    if (w >= 1280) return 0.82;
    if (w >= 1024) return 0.85;
    if (w >= 768) return 0.9;
    return 0.95; // mobile: একটু চওড়া কার্ড
  }

  // Function to open the URL in the browser
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

/// --- Single Card: minimal, eye-catchy ---
class _EbookCard extends StatelessWidget {
  final Ebook ebook;
  final int tileIndex;
  final VoidCallback onPrimary; // Read
  final VoidCallback onSecondary; // Renew / Continue

  const _EbookCard({
    required this.ebook,
    required this.tileIndex,
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final statusActive = (ebook.status == 'Active');
    final action = (ebook.button?.value ?? '').trim();

    // Primary/Secondary action resolve (Read = primary)
    final isRead =
        action.toLowerCase() == 'read e-book' || action.toLowerCase() == 'read';
    final isRenew = action.toLowerCase() == 'renew softcopy' ||
        action.toLowerCase() == 'renew';
    final isContinue = action.toLowerCase() == 'continue';

    final Color tint = statusActive
        ? AppColors.cardTintByIndex(tileIndex)
        : AppColors.cardTintRose;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isRead
            ? onPrimary
            : (ebook.button?.status == true ? onSecondary : null),
        child: Container(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Header: image + name
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Avatar(imageUrl: ebook.image, fallbackText: ebook.name),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ebook.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Status chip + optional action button (compact)
              Row(
                children: [
                  _StatusChip(active: statusActive),
                  const Spacer(),
                  if (ebook.button?.status == true) ...[
                    // Primary/Secondary compact button
                    if (isRead)
                      _ActionButton.primary(
                        label: 'Read',
                        onPressed: onPrimary,
                      )
                    else if (isRenew)
                      _ActionButton.tonal(
                        label: 'Renew',
                        onPressed: onSecondary,
                        color: AppColors.btnRenew,
                      )
                    else if (isContinue)
                      _ActionButton.tonal(
                        label: 'Continue',
                        onPressed: onSecondary,
                        color: AppColors.btnContinue,
                      )
                    else
                      _ActionButton.tonal(
                        label: (ebook.button!.value ?? 'Open'),
                        onPressed: onSecondary,
                        color: AppColors.textSecondary,
                      ),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              // Meta rows
              _MetaRow(
                icon: Icons.timelapse_outlined,
                label: 'Duration',
                value: ebook.validity,
              ),
              const SizedBox(height: 4),
              _MetaRow(
                icon: Icons.event_outlined,
                label: 'Ending',
                value: ebook.ending,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// --- Small circular avatar with fallback initial ---
class _Avatar extends StatelessWidget {
  final String imageUrl;
  final String fallbackText;

  const _Avatar({required this.imageUrl, required this.fallbackText});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.headerTintA, AppColors.headerTintB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Center(
                child: Text(
                  (fallbackText.isNotEmpty ? fallbackText[0] : '?')
                      .toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
      ),
    );
  }
}

/// --- Status chip (Active / Expired) ---
class _StatusChip extends StatelessWidget {
  final bool active;

  const _StatusChip({required this.active});

  @override
  Widget build(BuildContext context) {
    final bg = active ? AppColors.chipActiveBg : AppColors.chipExpiredBg;
    final text = active ? 'Active' : 'Expired';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// --- Meta row (icon + label: value) ---
class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// --- Compact action buttons ---
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool filled;

  const _ActionButton._({
    required this.label,
    required this.onPressed,
    this.color,
    required this.filled,
  });

  factory _ActionButton.primary({
    required String label,
    required VoidCallback onPressed,
  }) {
    return _ActionButton._(
      label: label,
      onPressed: onPressed,
      color: AppColors.btnRead,
      filled: true,
    );
  }

  factory _ActionButton.tonal({
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return _ActionButton._(
      label: label,
      onPressed: onPressed,
      color: color,
      filled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = (filled ? (color ?? AppColors.btnRead) : Colors.transparent);
    final fg = (filled ? Colors.white : (color ?? AppColors.textPrimary));
    final side = (filled
        ? BorderSide.none
        : BorderSide(color: (color ?? AppColors.textSecondary)));

    return SizedBox(
      height: 36,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          foregroundColor: fg,
          backgroundColor: bg,
          side: side,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
