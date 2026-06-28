import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() =>
      _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final AuthService _authService = AuthService();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String? _verificationId;

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      _showSnack('Enter a valid phone number');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.sendOTP(
        phoneNumber: '+91$phone',
        onVerificationCompleted: (credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential);
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => const HomeScreen()),
              (route) => false,
            );
          }
        },
        onVerificationFailed: (e) {
          setState(() => _isLoading = false);
          _showSnack(
              'Verification failed: ${e.message}');
        },
        onCodeSent: (vId, _) {
          setState(() {
            _isLoading = false;
            _otpSent = true;
            _verificationId = vId;
          });
          _showSnack('OTP sent successfully!');
        },
        onCodeAutoRetrievalTimeout: (_) {
          setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Error: $e');
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showSnack('Enter 6-digit OTP');
      return;
    }
    if (_verificationId == null) return;
    setState(() => _isLoading = true);
    try {
      await _authService.verifyOTP(
          _verificationId!, otp);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Invalid OTP. Please try again.');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Phone Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              _otpSent
                  ? 'Enter OTP'
                  : 'Enter Phone Number',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                      fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _otpSent
                  ? 'We sent a 6-digit code to +91${_phoneController.text}'
                  : 'We will send you a one-time verification code',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (!_otpSent) ...[
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+91 ',
                  hintText: '9876543210',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _sendOTP,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text('Send OTP'),
                ),
              ),
            ] else ...[
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                ),
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  hintText: '------',
                  prefixIcon:
                      Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _verifyOTP,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text('Verify OTP'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _otpSent = false;
                    _otpController.clear();
                  }),
                  child: const Text(
                      'Change Phone Number'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
