import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/sdg_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty) {
      setState(() {
        _error = 'Please fill in all fields.';
      });
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() {
        _error = 'Password must be at least 6 characters.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.registerWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() {
        _error = e.toString().contains('already-in-use')
            ? 'Email is already in use.'
            : 'Registration failed: $e';
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
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Join the SDG\nMovement 🌍',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Start earning SDG points and making an impact today.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppTheme.onSurfaceMuted),
              ),
              const SizedBox(height: 36),
              TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(hintText: 'Display name')),
              const SizedBox(height: 12),
              TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Email address')),
              const SizedBox(height: 12),
              TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      hintText: 'Password (min. 6 chars)')),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(_error!,
                      style:
                          const TextStyle(color: AppTheme.error, fontSize: 13)),
                ),
                const SizedBox(height: 12),
              ],
              SdgButton.primary(
                  label: _loading ? 'Creating account...' : 'Create Account',
                  onPressed: _loading ? null : _register),
              const SizedBox(height: 16),
              Center(
                  child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Already have an account? Sign In'))),
            ],
          ),
        ),
      ),
    );
  }
}
