import 'package:flutter/material.dart';
import '../../utils/routes.dart';
import '../../services/auth_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _authService = AuthService();
  bool loading = false;
  String? error;

  Future<void> _checkVerification() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await _authService.currentUser?.reload();
      final user = _authService.currentUser;
      if (user != null && user.emailVerified) {
        await _authService.signOut(); // Sign out after verification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verified. You can now log in.')),
          );
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      } else {
        setState(() {
          error = 'Email not yet verified. Please check your inbox.';
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkVerification(); // Check immediately on load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verify Your Email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (loading)
              const CircularProgressIndicator()
            else if (error != null)
              Text(error!, style: const TextStyle(color: Colors.redAccent))
            else
              const Text('Please check your email for a verification link.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkVerification,
              child: const Text('Check Verification Status'),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, Routes.login),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}