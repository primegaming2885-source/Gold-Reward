import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/coin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../models/user_model.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});
  @override
  State<WithdrawScreen> createState() =>
      _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _upiController = TextEditingController();
  final AuthService _authService = AuthService();
  final CoinService _coinService = CoinService();
  bool _isLoading = false;

  Future<void> _submitWithdrawal(UserModel user) async {
    if (!_formKey.currentState!.validate()) return;
    if (!user.canWithdraw) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Minimum 1000 coins required'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _confirmRow('Coins',
                '${AppConstants.minWithdrawCoins}'),
            _confirmRow(
                'Amount',
                '₹${AppConstants.coinsToRupees(AppConstants.minWithdrawCoins).toStringAsFixed(2)}'),
            _confirmRow('UPI ID', _upiController.text),
            _confirmRow('Name', _nameController.text),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () =>
                  Navigator.pop(ctx, true),
              child: const Text('Confirm')),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      final success = await _coinService.submitWithdrawal(
        userName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        upiId: _upiController.text.trim(),
        coins: AppConstants.minWithdrawCoins,
      );
      if (mounted) {
        if (success) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle),
                    child: const Icon(Icons.check,
                        size: 48,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text('Request Submitted!',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text(
                    'Admin will process within 24-48 hours.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Withdrawal failed. Try again.'),
                backgroundColor: AppTheme.error),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _confirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid =
        FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw')),
      body: StreamBuilder<UserModel?>(
        stream: _authService.streamUserData(uid),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return const Center(
                child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration:
                        AppTheme.goldGradientCard(),
                    child: Row(
                      children: [
                        const Icon(
                            Icons.monetization_on,
                            color: Colors.white,
                            size: 36),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Your Balance',
                                style: TextStyle(
                                    color:
                                        Colors.white70)),
                            Text(
                              '${user.coins} Coins',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.w800),
                            ),
                            Text(
                              '₹${user.rupeesValue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color:
                                      Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (user.canWithdraw
                              ? AppTheme.success
                              : AppTheme.error)
                          .withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: user.canWithdraw
                            ? AppTheme.success
                            : AppTheme.error,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          user.canWithdraw
                              ? Icons.check_circle
                              : Icons.info_outline,
                          color: user.canWithdraw
                              ? AppTheme.success
                              : AppTheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user.canWithdraw
                                ? 'You can withdraw ₹100 now!'
                                : 'Need ${AppConstants.minWithdrawCoins - user.coins} more coins',
                            style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                                color: user.canWithdraw
                                    ? AppTheme.success
                                    : AppTheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Withdrawal Details',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon:
                          Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        v?.isEmpty == true
                            ? 'Enter your name'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon:
                          Icon(Icons.phone_outlined),
                    ),
                    validator: (v) =>
                        v?.length != 10
                            ? 'Enter valid phone'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _upiController,
                    decoration: const InputDecoration(
                      labelText: 'UPI ID',
                      hintText: 'name@upi',
                      prefixIcon: Icon(Icons.payment),
                    ),
                    validator: (v) {
                      if (v?.isEmpty == true)
                        return 'Enter UPI ID';
                      if (!v!.contains('@'))
                        return 'Invalid UPI ID';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isLoading ||
                              !user.canWithdraw)
                          ? null
                          : () =>
                              _submitWithdrawal(user),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text(
                              'Withdraw ₹100'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    super.dispose();
  }
}
