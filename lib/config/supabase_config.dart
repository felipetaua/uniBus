import 'package:flutter_dotenv/flutter_dotenv.dart';

// Arquivo de configuração centralizado
class SupabaseConfig {
  // 🔧 Credenciais carregadas do .env
  static final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  static final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  // Configurações do app
  static const String appName = 'Presença Ônibus';
  static const String defaultPassword = 'estudante123';
  static const int busCapacity = 45;
  static const String busTime = '17h';
  static const String cutoffTime = '16h';
}
