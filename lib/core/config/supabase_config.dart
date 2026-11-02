// retrieve congif values when app starts
class SupabaseConfig {
  static const String url =
      String.fromEnvironment('SUPABASE_URL');

  static const String publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
}
