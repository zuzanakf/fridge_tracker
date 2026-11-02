import 'package:flutter/material.dart';
import 'package:fridge_tracker/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';

Future<void> main() async {
  // ensure flutter initialised before initialising supabase setup
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.url.isEmpty ||
      SupabaseConfig.publishableKey.isEmpty) {
    throw StateError('Missing Supabase configuration');
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  runApp(const FridgeApp());
}

class FridgeApp extends StatelessWidget {
  const FridgeApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fridge Tracker',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
