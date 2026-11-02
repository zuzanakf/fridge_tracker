
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();

  bool _isSignUp = false;
  bool _loading = false;

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (_isSignUp) {
        final response = await _auth.signUp(
          email: _email.text,
          password: _password.text,
        );

        if (response.session == null) {
          _message('Check your email to confirm your account.');

          if (mounted) {
            setState(() => _isSignUp = false);
          }
        }
      } else {
        await _auth.signIn(
          email: _email.text,
          password: _password.text,
        );
      }
    } on AuthException catch (error) {
      _message(error.message);
    } catch (error) {
      _message('Something went wrong. Please try again.');
      debugPrint('Authentication error: $error');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _forgotPassword() async {
    if (_email.text.trim().isEmpty) {
      _message('Enter your email address first.');
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.sendPasswordReset(_email.text);

      _message(
        'If an account exists, a reset email will be sent.',
      );
    } on AuthException catch (error) {
      _message(error.message);
    } catch (error) {
      _message('Could not send the reset email.');
      debugPrint('Password reset error: $error');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fridge Tracker')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isSignUp ? 'Create an account' : 'Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Use at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: Text(
                      _loading
                          ? 'Please wait...'
                          : (_isSignUp ? 'Sign up' : 'Log in'),
                    ),
                  ),

                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() => _isSignUp = !_isSignUp);
                          },
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Log in'
                          : 'New user? Create an account',
                    ),
                  ),

                  if (!_isSignUp)
                    TextButton(
                      onPressed: _loading ? null : _forgotPassword,
                      child: const Text('Forgot password?'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
