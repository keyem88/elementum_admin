enum Environment { dev, prod }

class AppConfig {
  final Environment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;

  AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  static late AppConfig current;

  static void setEnvironment(Environment env) {
    current = env == Environment.prod ? prod() : dev();
  }

  // Configuration for DEV
  static AppConfig dev() {
    return AppConfig(
      environment: Environment.dev,
      supabaseUrl: const String.fromEnvironment(
        'SUPABASE_URL_DEV',
        defaultValue: 'https://khwpsvnpdoijrhplzbii.supabase.co',
      ),
      supabaseAnonKey: const String.fromEnvironment(
        'SUPABASE_ANON_KEY_DEV',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtod3Bzdm5wZG9panJocGx6YmlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyOTgxODgsImV4cCI6MjA5MDg3NDE4OH0.CHZyWypky_SAtVnul4ZD2l76KIXSp2zJ4bsVVyq9oOY',
      ),
    );
  }

  // Configuration for PROD
  static AppConfig prod() {
    return AppConfig(
      environment: Environment.prod,
      supabaseUrl: const String.fromEnvironment(
        'SUPABASE_URL_PROD',
        defaultValue: '',
      ),
      supabaseAnonKey: const String.fromEnvironment(
        'SUPABASE_ANON_KEY_PROD',
        defaultValue: '',
      ),
    );
  }

  bool get isProd => environment == Environment.prod;
  bool get isDev => environment == Environment.dev;
}
