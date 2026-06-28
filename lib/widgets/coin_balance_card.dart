import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class CoinBalanceCard extends StatelessWidget {
  final int coins;
  const CoinBalanceCard({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.goldGradientCard(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Text(
                  '$coins',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'COINS',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '₹${AppConstants.coinsToRupees(coins).toStringAsFixed(2)} Value',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (coins < AppConstants.minWithdrawCoins) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: coins / AppConstants.minWithdrawCoins,
                backgroundColor:
                    Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.white),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              Text(
                '${AppConstants.minWithdrawCoins - coins} coins to withdraw',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
