import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageWithPlaceholder extends StatefulWidget {
  final String imageUrl;
  const ImageWithPlaceholder({super.key, required this.imageUrl});

  @override
  State<ImageWithPlaceholder> createState() => _ImageWithPlaceholderState();
}

class _ImageWithPlaceholderState extends State<ImageWithPlaceholder> {
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (!_isLoaded)
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(height: 200, width: double.infinity, color: Colors.white),
          ),
        Image.network(
          widget.imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _isLoaded = true);
              });
              return child;
            }
            return const SizedBox.shrink();
          },
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
        ),
      ],
    );
  }
}
