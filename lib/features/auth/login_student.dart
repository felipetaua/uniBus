import 'package:bus_attendance_app/features/gestor/gestor_navigation_menu.dart';
import 'package:bus_attendance_app/features/navegation_menu.dart';
import 'package:bus_attendance_app/features/auth/account_student.dart';
import 'package:bus_attendance_app/features/auth/register_student.dart';
import 'package:flutter/material.dart';
import 'package:bus_attendance_app/data/auth_services.dart';

/// Define os papéis de usuário disponíveis para login.
enum UserRole { estudante, gestor }

class LoginStudentPage extends StatefulWidget {
  const LoginStudentPage({super.key});

  @override
  State<LoginStudentPage> createState() => _LoginStudentPageState();
}

class _LoginStudentPageState extends State<LoginStudentPage> {
  bool _rememberPassword = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.estudante;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final isStudent = _selectedRole == UserRole.estudante;

    final user =
        isStudent
            ? await _authService.signInWithEmailAndPassword(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            )
            : await _authService.signInGestor(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );

    if (mounted) {
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) =>
                    isStudent
                        ? const NavigationMenu()
                        : const GestorNavigationMenu(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isStudent
                  ? 'E-mail ou senha inválidos.'
                  : 'Email ou senha incorretos, ou você não tem permissão de gestor.',
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Center(
              child: Image.asset('assets/images/logo-circle.png', height: 80),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Redefina sua senha',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Digite seu e-mail para receber um link de redefinição de senha.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Digite seu e-mail',
                    fillColor: Colors.grey[200],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _authService.sendPasswordResetEmail(
                        emailController.text,
                      );
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'E-mail de redefinição de senha enviado.',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A73EC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'Enviar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFC5FC61),
                    Color(0xFF9FE291),
                    Color(0xFF888AF4),
                    Color(0xFFA972F8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(0, 241, 242, 246),
                            Color(0xFFF1F2F6),
                          ],
                          stops: [0, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const accountStudentPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      'assets/images/unibus_logo_white.png',
                      height: 80,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SegmentedButton<UserRole>(
                      segments: const <ButtonSegment<UserRole>>[
                        ButtonSegment<UserRole>(
                          value: UserRole.estudante,
                          label: Text('Estudante'),
                          icon: Icon(Icons.school_outlined),
                        ),
                        ButtonSegment<UserRole>(
                          value: UserRole.gestor,
                          label: Text('Gestor'),
                          icon: Icon(Icons.business_center_outlined),
                        ),
                      ],
                      selected: <UserRole>{_selectedRole},
                      onSelectionChanged: (Set<UserRole> newSelection) {
                        setState(() {
                          _selectedRole = newSelection.first;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[700],
                        selectedForegroundColor: Colors.white,
                        selectedBackgroundColor: const Color(0xFF5A73EC),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _selectedRole == UserRole.estudante
                        ? 'Bem-vindo ao UniBus!'
                        : 'Área do Gestor',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedRole == UserRole.estudante
                        ? 'Organize sua rotina, confirme sua presença e ganhe recompensas por estar em dia. É rápido, simples e pensado para você.'
                        : 'Acompanhe os estudantes em tempo real, acesse relatórios e mantenha tudo sob controle.',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'exemplo@gmail.com',
                      fillColor: Colors.grey[300],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Senha',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Digite sua Senha',
                      fillColor: Colors.grey[300],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberPassword,
                            onChanged: (bool? value) {
                              setState(() {
                                _rememberPassword = value!;
                              });
                            },
                            activeColor: Colors.blueAccent,
                          ),
                          const Text(
                            'Lembrar a senha',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: const Text(
                            'Esqueceu a senha?',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blueAccent,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A73EC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                              : const Text(
                                'Entrar na conta',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'ou',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/google_logo.png',
                            height: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle "Continue with Apple"
                        print('Continue with Apple clicked');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/apple_logo.png',
                            height: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Continue with Apple',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Não possui uma conta?',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const RegisterStudentPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Criar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
