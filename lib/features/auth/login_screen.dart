import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/sdg_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.signInWithGoogle();
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() {
        _error = 'Google sign-in failed. Please try again.';
      });
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  Future<void> _signInWithEmail() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() {
        _error = 'Please enter email and password.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() {
        _error = 'Login failed: $e';
      });
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // Logo / Title
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('🌱', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 24),
              Text('Welcome to\nEcoRise',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Post SDG acts, earn points, change the world.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.onSurfaceMuted,
                    ),
              ),
              const SizedBox(height: 40),

              // Google Sign-In
              SdgButton.outlined(
                label: 'Continue with Google',
                icon: '🔵',
                onPressed: _loading ? null : _signInWithGoogle,
              ),
              const SizedBox(height: 16),

              // Divider
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child:
                      Text('or', style: Theme.of(context).textTheme.labelSmall),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email address'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
              ),
              const SizedBox(height: 20),

              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_error!,
                      style:
                          const TextStyle(color: AppTheme.error, fontSize: 13)),
                ),
              if (_error != null) const SizedBox(height: 12),

              SdgButton.primary(
                label: _loading ? 'Signing in...' : 'Sign In',
                onPressed: _loading ? null : _signInWithEmail,
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text("Don't have an account? Register →"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
