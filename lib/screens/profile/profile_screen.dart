import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid =
        FirebaseAuth.instance.currentUser?.uid ?? '';
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: StreamBuilder<UserModel?>(
        stream: authService.streamUserData(uid),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return const Center(
                child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            AppTheme.goldPrimary,
                        backgroundImage:
                            user.photoUrl.isNotEmpty
                                ? NetworkImage(
                                    user.photoUrl)
                                : null,
                        child: user.photoUrl.isEmpty
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0]
                                        .toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight:
                                      FontWeight.w800,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding:
                              const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.goldPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              size: 16,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                          fontWeight: FontWeight.w800),
                ),
                if (user.phone.isNotEmpty)
                  Text(user.phone,
                      style: const TextStyle(
                          color: Colors.grey)),
                if (user.email.isNotEmpty)
                  Text(user.email,
                      style: const TextStyle(
                          color: Colors.grey)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                          'Coins',
                          '${user.coins}',
                          Icons.monetization_on,
                          AppTheme.goldPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                          'Ads',
                          '${user.totalAdsWatched}',
                          Icons.play_circle,
                          Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                          'Quizzes',
                          '${user.totalQuizCorrect}',
                          Icons.quiz,
                          Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _infoTile(context, 'Exchange Rate',
                    '10 Coins = ₹1',
                    Icons.currency_exchange),
                _infoTile(
                    context,
                    'Min. Withdrawal',
                    '1000 Coins = ₹100',
                    Icons
                        .account_balance_wallet_outlined),
                _infoTile(
                    context,
                    'Member Since',
                    '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                    Icons.calendar_today),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const LoginScreen()),
                          (r) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout,
                        color: AppTheme.error),
                    label: const Text('Sign Out',
                        style: TextStyle(
                            color: AppTheme.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppTheme.error),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  12)),
                      padding:
                          const EdgeInsets.symmetric(
                              vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _infoTile(BuildContext context, String title,
      String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.goldPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              color: AppTheme.goldDark, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: Colors.grey, fontSize: 13)),
      ),
    );
  }
}
