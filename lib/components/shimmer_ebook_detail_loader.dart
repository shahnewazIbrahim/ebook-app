import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEbookDetailLoader extends StatelessWidget {
  const ShimmerEbookDetailLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 30,
              width: 250,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 50,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Container(
              height: 400,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Container(
              height: 40,
              width: 200,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
