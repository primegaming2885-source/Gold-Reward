import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/coin_balance_card.dart';
import '../../widgets/home_action_button.dart';
import '../../widgets/popunder_ad_widget.dart';
import '../quiz/quiz_screen.dart';
import '../withdraw/withdraw_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';
import 'reward_ad_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PopunderAdHelper.show(context);
    });
    _schedulePeriodicAd();
  }

  void _schedulePeriodicAd() {
    Future.delayed(const Duration(minutes: 3), () {
      if (mounted) {
        PopunderAdHelper.show(context);
        _schedulePeriodicAd();
      }
    });
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => const LoginScreen()),
        (r) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const LoginScreen();

    return StreamBuilder<UserModel?>(
      stream: _authService.streamUserData(uid),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, size: 26),
                SizedBox(width: 8),
                Text('Gold Reward'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const ProfileScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _signOut,
              ),
            ],
          ),
          body: Column(
            children: [
              const BannerAdWidget(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${user?.name.split(' ').first ?? 'User'}! 👋',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight:
                                            FontWeight.w700),
                              ),
                              Text(
                                'Keep earning coins!',
                                style: TextStyle(
                                    color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CoinBalanceCard(
                            coins: user?.coins ?? 0),
                        const SizedBox(height: 16),
                        const NativeBannerAdWidget(),
                        const SizedBox(height: 16),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16),
                          child: Text('Earn Coins',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight:
                                          FontWeight.w700)),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16),
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.1,
                            children: [
                              HomeActionButton(
                                icon: Icons
                                    .play_circle_filled,
                                label:
                                    'Watch Ads\n+2 Coins',
                                color: Colors.orange,
                                delay: 100,
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const RewardAdScreen())),
                              ),
                              HomeActionButton(
                                icon: Icons
                                    .calculate_outlined,
                                label:
                                    'Math Quiz\n+1 Coin',
                                color: Colors.blue,
                                delay: 200,
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const QuizScreen())),
                              ),
                              HomeActionButton(
                                icon: Icons
                                    .account_balance_wallet_outlined,
                                label: 'Withdraw\nCoins',
                                color: Colors.green,
                                delay: 300,
                                onTap: () async {
                                  await PopunderAdHelper
                                      .show(context);
                                  if (mounted) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const WithdrawScreen()));
                                  }
                                },
                              ),
                              HomeActionButton(
                                icon: Icons.history,
                                label: 'History',
                                color: Colors.purple,
                                delay: 400,
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const HistoryScreen())),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const NativeBannerAdWidget(),
                        const SizedBox(height: 16),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16),
                          child: Text('Your Stats',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight:
                                          FontWeight.w700)),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _statCard(
                                    'Ads Watched',
                                    '${user?.totalAdsWatched ?? 0}',
                                    Icons
                                        .play_circle_outline,
                                    Colors.orange),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _statCard(
                                    'Quiz Correct',
                                    '${user?.totalQuizCorrect ?? 0}',
                                    Icons
                                        .check_circle_outline,
                                    Colors.green),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _statCard(
                                    'Withdrawals',
                                    '${user?.totalWithdrawn ?? 0}',
                                    Icons.payment,
                                    Colors.blue),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16),
                          child: Container(
                            padding:
                                const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.goldPrimary
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppTheme.goldPrimary
                                      .withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color:
                                        AppTheme.goldDark),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                          '10 Coins = ₹1',
                                          style: TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                              color: AppTheme
                                                  .goldDark)),
                                      Text(
                                          'Min withdrawal: 1000 Coins = ₹100',
                                          style: TextStyle(
                                              color: Colors
                                                  .grey,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 72),
                      ],
                    ),
                  ),
                ),
              ),
              const SocialBarAdWidget(),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String label, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600])),
        ],
      ),
    );
  }
}
