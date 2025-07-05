import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _matriculaController = TextEditingController();
  bool _isLoading = false;
  bool _useEmail = true;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);

    try {
      String identifier = _useEmail
          ? _emailController.text.trim()
          : _matriculaController.text.trim();

      if (identifier.isEmpty) {
        throw Exception('Por favor, preencha o campo');
      }

      if (_useEmail) {
        // Tentar fazer login primeiro
        try {
          await Supabase.instance.client.auth.signInWithPassword(
            email: identifier,
            password: 'estudante123', // Senha padrão para MVP
          );
        } catch (e) {
          // Se não conseguir fazer login, criar conta automaticamente
          await _createAccount(identifier);
        }
      } else {
        // Para matrícula, criar email fictício e conta
        final email = '$identifier@estudante.app';
        try {
          await Supabase.instance.client.auth.signInWithPassword(
            email: email,
            password: 'estudante123',
          );
        } catch (e) {
          await _createAccount(email, matricula: identifier);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createAccount(String email, {String? matricula}) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: 'estudante123', // Senha padrão para MVP
        data: {
          'name': matricula ?? email.split('@')[0],
          'role': 'student',
          'matricula': matricula,
        },
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada e login realizado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      throw Exception('Erro ao criar conta: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.directions_bus,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                'Presença Ônibus',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Confirme sua presença diária',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Toggle entre email e matrícula
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _useEmail = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _useEmail ? Colors.blue : Colors.grey[300],
                        foregroundColor:
                            _useEmail ? Colors.white : Colors.black,
                      ),
                      child: const Text('E-mail'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _useEmail = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !_useEmail ? Colors.blue : Colors.grey[300],
                        foregroundColor:
                            !_useEmail ? Colors.white : Colors.black,
                      ),
                      child: const Text('Matrícula'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _useEmail ? _emailController : _matriculaController,
                decoration: InputDecoration(
                  labelText: _useEmail ? 'E-mail' : 'Matrícula',
                  prefixIcon: Icon(_useEmail ? Icons.email : Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType:
                    _useEmail ? TextInputType.emailAddress : TextInputType.text,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Entrar / Criar Conta'),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _isLoading ? null : _showManualSignup,
                child: const Text('Criar Nova Conta'),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => _showOrganizerLogin(),
                child: const Text('Sou organizador'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrganizerLogin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acesso Organizador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'E-mail do organizador',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (email) async {
                Navigator.pop(context);
                await Supabase.instance.client.auth.signInWithOtp(
                  email: email,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Link enviado para $email')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showManualSignup() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final matriculaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Nova Conta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: matriculaController,
                decoration: const InputDecoration(
                  labelText: 'Matrícula (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Senha padrão: estudante123',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha nome e e-mail')),
                );
                return;
              }

              Navigator.pop(context);

              try {
                setState(() => _isLoading = true);

                await Supabase.instance.client.auth.signUp(
                  email: emailController.text.trim(),
                  password: 'estudante123',
                  data: {
                    'name': nameController.text.trim(),
                    'role': 'student',
                    'matricula': matriculaController.text.trim(),
                  },
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conta criada com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao criar conta: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Criar Conta'),
          ),
        ],
      ),
    );
  }
}
