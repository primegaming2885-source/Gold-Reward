import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/coin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/popunder_ad_widget.dart';

class RewardAdScreen extends StatefulWidget {
  const RewardAdScreen({super.key});
  @override
  State<RewardAdScreen> createState() =>
      _RewardAdScreenState();
}

class _RewardAdScreenState extends State<RewardAdScreen> {
  final CoinService _coinService = CoinService();
  late WebViewController _controller;
  bool _adLoaded = false;
  bool _coinsClaimed = false;
  int _watchSeconds = 0;
  static const int _requiredSeconds = 30;
  bool _adCompleted = false;
  int _totalEarned = 0;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    setState(() {
      _adLoaded = false;
      _adCompleted = false;
      _coinsClaimed = false;
      _watchSeconds = 0;
    });
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          setState(() => _adLoaded = true);
          _startTimer();
          PopunderAdHelper.show(context);
        },
      ))
      ..loadHtmlString(AppConstants.rewardAdScript);
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _adCompleted) return;
      setState(() => _watchSeconds++);
      if (_watchSeconds >= _requiredSeconds) {
        setState(() => _adCompleted = true);
      } else {
        _startTimer();
      }
    });
  }

  Future<void> _claimAndNext() async {
    if (_coinsClaimed) return;
    setState(() => _coinsClaimed = true);
    final success = await _coinService.addRewardAdCoins();
    if (!mounted) return;
    if (success) {
      setState(
          () => _totalEarned += AppConstants.rewardAdCoins);
      _showCoinDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error adding coins'),
            backgroundColor: AppTheme.error),
      );
      setState(() => _coinsClaimed = false);
    }
  }

  void _showCoinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                  color: AppTheme.goldPrimary,
                  shape: BoxShape.circle),
              child: const Icon(Icons.monetization_on,
                  size: 44, color: Colors.white),
            ),
            const SizedBox(height: 14),
            const Text('+2 Coins Earned!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
                'Session total: $_totalEarned coins',
                style:
                    const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _loadAd();
                  },
                  child: const Text('Watch More'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (_watchSeconds / _requiredSeconds).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch & Earn'),
        actions: [
          if (_totalEarned > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Text('+$_totalEarned coins',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(
                16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _adCompleted
                          ? '✅ Ad Complete!'
                          : 'Watch for 2 Coins',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _adCompleted
                            ? AppTheme.success
                            : null,
                      ),
                    ),
                    Text(
                      _adCompleted
                          ? 'Claim now!'
                          : '${_requiredSeconds - _watchSeconds}s remaining',
                      style: TextStyle(
                          color: _adCompleted
                              ? AppTheme.success
                              : Colors.grey,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor:
                        Colors.grey.withOpacity(0.2),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(
                      _adCompleted
                          ? AppTheme.success
                          : AppTheme.goldPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (_adLoaded)
                  WebViewWidget(controller: _controller),
                if (!_adLoaded)
                  const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                            color: AppTheme.goldPrimary),
                        SizedBox(height: 16),
                        Text('Loading ad...'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    (_adCompleted && !_coinsClaimed)
                        ? _claimAndNext
                        : null,
                icon:
                    const Icon(Icons.monetization_on),
                label: Text(_coinsClaimed
                    ? 'Claimed!'
                    : _adCompleted
                        ? 'Claim 2 Coins & Watch More'
                        : 'Waiting...'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
