
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home_page.dart';
import 'login_page.dart';
import 'update_password_page.dart';


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Session? _session;
  late final StreamSubscription<AuthState> _subscription;

  bool _recoveringPassword = false;

  @override
  void initState() {
    super.initState();

    final auth = Supabase.instance.client.auth;
    _session = auth.currentSession;

    _subscription = auth.onAuthStateChange.listen(
      (data) {
        if (!mounted) return;

        setState(() {
          _session = data.session;

          if (data.event == AuthChangeEvent.passwordRecovery) {
            _recoveringPassword = true;
          }

          if (data.event == AuthChangeEvent.signedOut) {
            _recoveringPassword = false;
          }
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Auth stream error: $error');
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_recoveringPassword && _session != null) {
      return UpdatePasswordPage(
        onComplete: () {
          setState(() => _recoveringPassword = false);
        },
      );
    }

    if (_session == null) {
      return const LoginPage();
    }

    return const HomePage();
  }
}
