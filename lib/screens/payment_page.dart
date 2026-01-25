import 'package:ebook_project/components/app_layout.dart';
import 'package:ebook_project/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PaymentPage extends StatefulWidget {
  final String title;
  final Uri url;
  final String? subtitle;

  const PaymentPage({
    super.key,
    required this.title,
    required this.url,
    this.subtitle,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  double _progress = 0;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: widget.title,
      showDrawer: false,
      showNavBar: false,
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url.toString())),
            initialOptions: InAppWebViewGroupOptions(
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
              ),
            ),
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
                if (_hasError) _hasError = false;
              });
            },
            onReceivedError: (_, __, ___) {
              setState(() {
                _hasError = true;
              });
            },
            onReceivedHttpError: (_, __, ___) {
              setState(() {
                _hasError = true;
              });
            },
          ),
          if (_progress < 1 && !_hasError)
            Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(
                value: _progress,
                color: AppColors.primary,
                backgroundColor: AppColors.onGradientSoft,
              ),
            ),
          if (_hasError)
            Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unable to load payment page.\nPlease check your connection and try again.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _progress = 0;
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
