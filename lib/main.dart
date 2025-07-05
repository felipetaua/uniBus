import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'screens/login_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/organizer_dashboard.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(AppInitializer());
}

class AppInitializer extends StatelessWidget {
  // Cria um Future que encapsula toda a lógica de inicialização.
  final Future<void> _initFuture = _initializeApp();

  static Future<void> _initializeApp() async {
    // Garante que os bindings do Flutter estão prontos.
    WidgetsFlutterBinding.ensureInitialized();
    // Carrega as variáveis de ambiente.
    await dotenv.load(fileName: "dotenv");
    // Inicializa o Supabase com as credenciais carregadas.
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        // Se a inicialização terminou com sucesso, mostra o app principal.
        if (snapshot.connectionState == ConnectionState.done) {
          // Se houve um erro na inicialização, mostra uma tela de erro.
          if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text(
                      'Falha ao inicializar o aplicativo: ${snapshot.error}'),
                ),
              ),
            );
          }
          // Tudo certo, vamos para o app.
          return BusAttendanceApp();
        }

        // Enquanto a inicialização está em andamento, mostra uma tela de carregamento.
        return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class BusAttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: SupabaseConfig.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.session != null) {
          final user = snapshot.data!.session!.user;
          final isOrganizer = user.userMetadata?['role'] == 'organizer';
          final profileCompleted =
              user.userMetadata?['profile_completed'] == true;

          // Se é estudante e não completou o perfil, mostrar tela de boas-vindas
          if (!isOrganizer && !profileCompleted) {
            return WelcomeScreen();
          }

          return isOrganizer ? OrganizerDashboard() : StudentDashboard();
        }
        return LoginScreen();
      },
    );
  }
}
