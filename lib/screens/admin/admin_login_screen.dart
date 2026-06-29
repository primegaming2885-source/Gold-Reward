import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() =>
      _AdminLoginScreenState();
}

class _AdminLoginScreenState
    extends State<AdminLoginScreen> {
  final AuthService _authService = AuthService();
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  void _checkAdmin() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        _authService.isAdmin(user.email)) {
      setState(() => _verified = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_verified) {
      return const AdminDashboardScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Access'),
        backgroundColor: Colors.red[700],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('Access Denied',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Only admin (${AppConstants.adminEmail}) can access this panel.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
