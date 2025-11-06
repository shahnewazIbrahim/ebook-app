import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppModal extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onClose;

  const AppModal({
    super.key,
    required this.title,
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: w * 0.9,
              constraints: const BoxConstraints(maxHeight: 520),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black26)],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppModalLoader extends StatelessWidget {
  const AppModalLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        Center(
          child: LoadingAnimationWidget.fourRotatingDots(
            color: Colors.white,
            size: 50,
          ),
        ),
      ],
    );
  }
}
