import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EbookSkeletonCard extends StatelessWidget {
  const EbookSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 18, width: double.infinity, color: Colors.white),
              const SizedBox(height: 8),
              Container(height: 12, width: double.infinity, color: Colors.white),
              const SizedBox(height: 12),
              Row(
                children: List.generate(
                  3,
                      (index) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 30,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
