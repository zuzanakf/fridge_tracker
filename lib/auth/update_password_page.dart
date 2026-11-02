
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  State<UpdatePasswordPage> createState() =>
      _UpdatePasswordPageState();
}

class _UpdatePasswordPageState
    extends State<UpdatePasswordPage> {
  final _password = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;

  Future<void> _updatePassword() async {
    if (_password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a password of at least 6 characters'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.updatePassword(_password.text);

      if (!mounted) return;
      widget.onComplete();
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _updatePassword,
                child: const Text('Update password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
