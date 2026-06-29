import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/coin_service.dart';
import '../../theme/app_theme.dart';
import '../../models/reward_history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final CoinService _coinService = CoinService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Rewards'),
            Tab(text: 'Quiz'),
            Tab(text: 'Withdraw'),
            Tab(text: 'Ads'),
          ],
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black45,
          indicatorColor: AppTheme.goldDark,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RewardHistoryTab(
              coinService: _coinService),
          _QuizHistoryTab(coinService: _coinService),
          _WithdrawHistoryTab(
              coinService: _coinService),
          _AdsHistoryTab(coinService: _coinService),
        ],
      ),
    );
  }
}

class _RewardHistoryTab extends StatelessWidget {
  final CoinService coinService;
  const _RewardHistoryTab(
      {required this.coinService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RewardHistoryModel>>(
      stream: coinService.getRewardHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _emptyState('No reward history yet',
              Icons.play_circle_outline);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            return _historyCard(
              context,
              icon: Icons.play_circle_filled,
              iconColor: Colors.orange,
              title: item.description,
              subtitle: _formatDate(item.createdAt),
              trailing: '+${item.coins} Coins',
              trailingColor: AppTheme.success,
            );
          },
        );
      },
    );
  }
}

class _QuizHistoryTab extends StatelessWidget {
  final CoinService coinService;
  const _QuizHistoryTab({required this.coinService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: coinService.getQuizHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _emptyState('No quiz history yet',
              Icons.quiz_outlined);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            final isCorrect =
                item['isCorrect'] as bool;
            return _historyCard(
              context,
              icon: isCorrect
                  ? Icons.check_circle
                  : Icons.cancel,
              iconColor: isCorrect
                  ? AppTheme.success
                  : AppTheme.error,
              title: 'Quiz: ${item['question']}',
              subtitle: _formatTimestamp(
                  item['createdAt']),
              trailing: isCorrect
                  ? '+${item['coins']} Coin'
                  : 'Wrong',
              trailingColor: isCorrect
                  ? AppTheme.success
                  : AppTheme.error,
            );
          },
        );
      },
    );
  }
}

class _WithdrawHistoryTab extends StatelessWidget {
  final CoinService coinService;
  const _WithdrawHistoryTab(
      {required this.coinService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: coinService.getWithdrawHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _emptyState(
              'No withdrawal history yet',
              Icons
                  .account_balance_wallet_outlined);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            final status = item['status'] as String;
            Color statusColor = Colors.orange;
            if (status == 'successful')
              statusColor = AppTheme.success;
            if (status == 'rejected')
              statusColor = AppTheme.error;
            return _historyCard(
              context,
              icon: Icons.payment,
              iconColor: statusColor,
              title:
                  '₹${item['amount']} Withdrawal',
              subtitle: _formatTimestamp(
                  item['createdAt']),
              trailing: status.toUpperCase(),
              trailingColor: statusColor,
            );
          },
        );
      },
    );
  }
}

class _AdsHistoryTab extends StatelessWidget {
  final CoinService coinService;
  const _AdsHistoryTab({required this.coinService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RewardHistoryModel>>(
      stream: coinService.getRewardHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator());
        }
        final items = (snapshot.data ?? [])
            .where((h) => h.type == 'reward_ad')
            .toList();
        if (items.isEmpty) {
          return _emptyState('No ads watched yet',
              Icons.play_circle_outline);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            return _historyCard(
              context,
              icon: Icons.ondemand_video,
              iconColor: Colors.orange,
              title: 'Reward Ad Watched',
              subtitle: _formatDate(item.createdAt),
              trailing: '+${item.coins} Coins',
              trailingColor: AppTheme.success,
            );
          },
        );
      },
    );
  }
}

Widget _historyCard(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required String trailing,
  required Color trailingColor,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              color: Colors.grey, fontSize: 12)),
      trailing: Text(trailing,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: trailingColor,
              fontSize: 13)),
    ),
  );
}

Widget _emptyState(String text, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(text,
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16)),
      ],
    ),
  );
}

String _formatDate(DateTime dt) {
  return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}

String _formatTimestamp(dynamic ts) {
  if (ts is Timestamp) {
    return _formatDate(ts.toDate());
  }
  return '';
}
