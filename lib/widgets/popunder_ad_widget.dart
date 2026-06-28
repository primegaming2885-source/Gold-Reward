import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/constants.dart';

class PopunderAdHelper {
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => const _PopunderDialog(),
    );
  }
}

class _PopunderDialog extends StatefulWidget {
  const _PopunderDialog();
  @override
  State<_PopunderDialog> createState() =>
      _PopunderDialogState();
}

class _PopunderDialogState extends State<_PopunderDialog> {
  late final WebViewController _controller;
  int _countdown = 5;
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(AppConstants.popunderScript);
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown > 0) {
        _tick();
      } else {
        setState(() => _canClose = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      shape: const RoundedRectangleBorder(),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.75,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            Positioned(
              top: 10,
              right: 10,
              child: _canClose
                  ? GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close,
                                color: Colors.white,
                                size: 16),
                            SizedBox(width: 4),
                            Text('Close',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Close in $_countdown',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
