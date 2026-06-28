import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/constants.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});
  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(AppConstants.bannerAdScript);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: WebViewWidget(controller: _controller),
    );
  }
}

class NativeBannerAdWidget extends StatefulWidget {
  const NativeBannerAdWidget({super.key});
  @override
  State<NativeBannerAdWidget> createState() =>
      _NativeBannerAdWidgetState();
}

class _NativeBannerAdWidgetState
    extends State<NativeBannerAdWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(AppConstants.nativeBannerScript);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8),
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withOpacity(0.08),
      ),
      clipBehavior: Clip.hardEdge,
      child: WebViewWidget(controller: _controller),
    );
  }
}

class SocialBarAdWidget extends StatefulWidget {
  const SocialBarAdWidget({super.key});
  @override
  State<SocialBarAdWidget> createState() =>
      _SocialBarAdWidgetState();
}

class _SocialBarAdWidgetState
    extends State<SocialBarAdWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(AppConstants.socialBarScript);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: WebViewWidget(controller: _controller),
    );
  }
}
