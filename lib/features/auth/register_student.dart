import 'package:bus_attendance_app/core/utils/lgpd_content.dart';
import 'package:bus_attendance_app/data/auth_services.dart';
import 'package:bus_attendance_app/features/auth/account_student.dart';
import 'package:bus_attendance_app/features/auth/login_student.dart';
import 'package:bus_attendance_app/features/estudante/home/estudante_home.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class registerStudentPage extends StatefulWidget {
  const registerStudentPage({super.key});

  @override
  State<registerStudentPage> createState() => registerStudentPageState();
}

// ignore: camel_case_types
class registerStudentPageState extends State<registerStudentPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _rememberPassword = false;
  bool _isPasswordVisible = false;
  bool _acceptedTerms = false;

  // bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você deve aceitar os termos de uso.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = await _authService.registerStudent(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const StudentHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao criar a conta. Tente novamente.'),
        ),
      );
    }
  }

  void _showLegalDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 40,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Termos de Uso e Política de Privacidade',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  const Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              termosEPoliticaUnibus,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fechar'),
                    ),
                  ),
                ],
              ),
            ),
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
                  const Text(
                    'Crie sua conta de estudante',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use seu e-mail institucional ou pessoal. Você poderá vincular sua linha de ônibus logo após o cadastro',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nome',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Seu nome',
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
                      TextButton(
                        onPressed: () {
                          // Handle "Esqueceu a senha?"
                          print('Esqueceu a senha? clicked');
                        },
                        child: const Text(
                          'Esqueceu a senha?',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                        activeColor: Colors.blueAccent,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _showLegalDialog,
                          child: const Text.rich(
                            TextSpan(
                              text: 'Li e aceito os ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Termos de Uso',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: ' e a '),
                                TextSpan(
                                  text: 'Política de Privacidade',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
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
                      onPressed: _acceptedTerms ? _registerUser : null,
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
                                'Criar sua conta',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Já possui uma conta?',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const loginStudentPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Entrar',
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
