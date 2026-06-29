import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this);
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
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Withdrawals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DashboardTab(
              adminService: _adminService),
          _WithdrawalsTab(
              adminService: _adminService),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final AdminService adminService;
  const _DashboardTab({required this.adminService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: adminService.getDashboardStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator());
        }
        final stats = snapshot.data ?? {};
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text('Overview',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _statCard(
                      'Total Users',
                      '${stats['totalUsers'] ?? 0}',
                      Icons.people,
                      Colors.blue),
                  _statCard(
                      'Total Coins',
                      '${stats['totalCoins'] ?? 0}',
                      Icons.monetization_on,
                      AppTheme.goldPrimary),
                  _statCard(
                      'Ads Watched',
                      '${stats['totalAdsWatched'] ?? 0}',
                      Icons.play_circle,
                      Colors.orange),
                  _statCard(
                      'Withdrawals',
                      '${stats['totalWithdrawals'] ?? 0}',
                      Icons.payment,
                      Colors.green),
                  _statCard(
                      'Pending ₹',
                      '₹${(stats['totalPendingAmount'] ?? 0).toStringAsFixed(2)}',
                      Icons.pending_actions,
                      Colors.red),
                  _statCard(
                      'Today Users',
                      '${stats['todayUsers'] ?? 0}',
                      Icons.today,
                      Colors.purple),
                ],
              ),
            ],
          ),
        );
      },
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}

class _WithdrawalsTab extends StatefulWidget {
  final AdminService adminService;
  const _WithdrawalsTab(
      {required this.adminService});
  @override
  State<_WithdrawalsTab> createState() =>
      _WithdrawalsTabState();
}

class _WithdrawalsTabState
    extends State<_WithdrawalsTab> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'all',
                'pending',
                'approved',
                'rejected',
                'successful'
              ]
                  .map((f) => Padding(
                        padding:
                            const EdgeInsets.only(
                                right: 8),
                        child: FilterChip(
                          label:
                              Text(f.toUpperCase()),
                          selected: _filter == f,
                          onSelected: (_) =>
                              setState(
                                  () => _filter = f),
                          selectedColor: AppTheme
                              .goldPrimary
                              .withOpacity(0.2),
                          checkmarkColor:
                              AppTheme.goldDark,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<
              List<Map<String, dynamic>>>(
            stream:
                widget.adminService.getAllWithdrawals(
              status: _filter == 'all'
                  ? null
                  : _filter,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator());
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(
                    child: Text(
                        'No withdrawals found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16),
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  return _withdrawCard(
                      ctx, items[i]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _withdrawCard(
      BuildContext context,
      Map<String, dynamic> item) {
    final status = item['status'] as String;
    Color statusColor = Colors.orange;
    if (status == 'successful')
      statusColor = AppTheme.success;
    if (status == 'rejected')
      statusColor = AppTheme.error;
    if (status == 'approved')
      statusColor = Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['userName'] ?? 'Unknown',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        statusColor.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(20),
                    border:
                        Border.all(color: statusColor),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.phone,
                item['phone'] ?? ''),
            _infoRow(Icons.payment,
                item['upiId'] ?? ''),
            _infoRow(
                Icons.monetization_on,
                '${item['coins']} Coins = ₹${item['amount']}'),
            const SizedBox(height: 12),
            if (status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _updateStatus(
                              context,
                              item['id'],
                              'rejected'),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            AppTheme.error,
                        side: const BorderSide(
                            color: AppTheme.error),
                      ),
                      child:
                          const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateStatus(
                              context,
                              item['id'],
                              'approved'),
                      style:
                          ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue),
                      child:
                          const Text('Approve'),
                    ),
                  ),
                ],
              )
            else if (status == 'approved')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateStatus(
                      context,
                      item['id'],
                      'successful'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.success),
                  child: const Text(
                      'Mark Successful'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context,
      String id, String status) async {
    final success = await widget.adminService
        .updateWithdrawalStatus(id, status, null);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Status updated to $status'
              : 'Update failed'),
          backgroundColor: success
              ? AppTheme.success
              : AppTheme.error,
        ),
      );
    }
  }
}
