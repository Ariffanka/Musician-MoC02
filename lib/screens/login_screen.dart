import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _session = SessionManager();
  bool _loading = false;
  bool _isLoggedIn = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final loggedIn = await _session.isLoggedIn();
    if (loggedIn) {
      final data = await _session.getUserData();
      setState(() {
        _isLoggedIn = true;
        _userName = data['name'] ?? '';
      });
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _loading = true);
    final user = await _auth.signInWithGoogle();
    if (user != null) {
      await _session.saveUserSession(
        email: user['email']!,
        name: user['name']!,
        photoUrl: user['photo']!,
      );
      setState(() {
        _isLoggedIn = true;
        _userName = user['name']!;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.music_note, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 28),
              const Text(
                'MUSICIAN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLoggedIn ? 'Welcome back, $_userName!' : 'Your music, your world.',
                style: const TextStyle(color: Colors.white38, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              if (_loading)
                const CircularProgressIndicator(color: Colors.white)
              else if (_isLoggedIn)
                _StartButton(onTap: _goToHome)
              else
                _GoogleButton(onTap: _handleGoogleLogin),
              const SizedBox(height: 16),
              const Text(
                'BY ARFFNK',
                style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              child: _buildGoogleLogo(),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF4285F4),
                Color(0xFF34A853),
                Color(0xFFFBBC05),
                Color(0xFFEA4335),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
        const Text(
          'G',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4285F4),
          ),
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFF4E9E6),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Start',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}