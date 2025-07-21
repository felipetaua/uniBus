import 'package:bus_attendance_app/features/auth/account_student.dart';
import 'package:bus_attendance_app/features/auth/login_student.dart';
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
  bool _acceptedTerms = false; // Adicione esta linha

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
    super.dispose();
  }

  void _showLegalDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Termos de Uso e Política de Privacidade'),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.65,
              child: const Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📜 Termos de Uso – UniBus\n\n'
                        'Última atualização: 05/07/2025\n\n'
                        '1. Aceitação dos Termos\n'
                        'Ao criar uma conta ou utilizar o aplicativo UniBus, você concorda com estes Termos de Uso e com a Política de Privacidade. Caso não concorde, não utilize o aplicativo.\n\n'
                        '2. Sobre o UniBus\n'
                        'UniBus é um aplicativo que visa organizar o transporte universitário por meio de check-ins, rastreamento de rotas e comunicação entre estudantes e gestores, com elementos de gamificação.\n\n'
                        '3. Conta de Usuário\n'
                        '• O usuário pode ser Estudante ou Gestor.\n'
                        '• Ao se cadastrar, você é responsável por manter suas informações corretas e atualizadas.\n'
                        '• Não é permitido compartilhar sua conta com outras pessoas.\n\n'
                        '4. Responsabilidades do Usuário\n'
                        'Você se compromete a:\n'
                        '• Utilizar o app de forma ética e dentro da lei;\n'
                        '• Não burlar o sistema de check-in;\n'
                        '• Respeitar os demais usuários e gestores;\n'
                        '• Não tentar acessar áreas administrativas sem autorização.\n\n'
                        '5. Moeda Virtual e Gamificação\n'
                        '• O app pode oferecer moedas virtuais (ex: “Rodinhas” ou “Unicoins”) que são acumuladas com base no uso do sistema.\n'
                        '• Essas moedas não têm valor real e são destinadas exclusivamente para fins internos (ex: personalização de avatar).\n'
                        '• A administração pode alterar regras e recompensas a qualquer momento.\n\n'
                        '6. Limitações de Responsabilidade\n'
                        '• A equipe do UniBus não se responsabiliza por atrasos, problemas técnicos, quedas de internet ou falhas externas.\n'
                        '• O app serve como ferramenta de apoio, mas não substitui a comunicação oficial com a instituição ou empresa de transporte.\n\n'
                        '7. Suspensão de Conta\n'
                        'O app poderá suspender ou excluir uma conta em caso de:\n'
                        '• Fraude;\n'
                        '• Uso indevido das funcionalidades;\n'
                        '• Repetidas infrações aos termos.\n\n'
                        '8. Modificações\n'
                        'Os Termos de Uso podem ser modificados a qualquer momento, sendo responsabilidade do usuário consultá-los periodicamente.\n\n'
                        '9. Contato\n'
                        'Para dúvidas, entre em contato pelo e-mail: seuemail@email.com\n\n'
                        '---\n\n'
                        '🔐 Política de Privacidade – UniBus\n\n'
                        'Última atualização: 05/07/2025\n\n'
                        '1. Coleta de Dados\n'
                        'Coletamos os seguintes dados:\n'
                        '• Nome, e-mail, matrícula (se informado);\n'
                        '• Perfil (estudante ou gestor);\n'
                        '• Check-ins realizados;\n'
                        '• Informações sobre localização, somente quando o usuário permitir;\n'
                        '• Dados de personalização do avatar;\n'
                        '• Dados de login (Google ou Facebook, quando utilizados).\n\n'
                        '2. Uso das Informações\n'
                        'As informações são utilizadas para:\n'
                        '• Confirmar presença nos ônibus;\n'
                        '• Gerar relatórios para gestores;\n'
                        '• Exibir rotas e horários;\n'
                        '• Aplicar recompensas e moedas virtuais;\n'
                        '• Melhorar a experiência do usuário.\n\n'
                        '3. Compartilhamento de Dados\n'
                        '• Os dados não são compartilhados com terceiros sem consentimento, exceto quando exigido por lei.\n'
                        '• Gestores têm acesso apenas aos dados necessários para gerenciamento das rotas e usuários de sua linha.\n\n'
                        '4. Localização\n'
                        '• O uso de localização é opcional e apenas utilizado para exibir a posição do ônibus, se habilitado.\n'
                        '• O app não coleta sua localização em segundo plano.\n\n'
                        '5. Armazenamento e Segurança\n'
                        '• Os dados são armazenados no Firebase, com criptografia e boas práticas de segurança.\n'
                        '• Senhas são protegidas por hash e não podem ser acessadas nem pela equipe do app.\n\n'
                        '6. Seus Direitos\n'
                        'Você pode:\n'
                        '• Solicitar a exclusão de sua conta e dados;\n'
                        '• Atualizar suas informações de perfil;\n'
                        '• Revogar permissões de localização a qualquer momento.\n\n'
                        '7. Cookies e tecnologias similares\n'
                        'O app não utiliza cookies, mas pode usar serviços de terceiros (como Google Analytics for Firebase) para entender melhor o uso do aplicativo.\n\n'
                        '8. Alterações nesta Política\n'
                        'Essa política pode ser atualizada. Se mudanças significativas forem feitas, os usuários serão notificados.\n\n'
                        '9. Contato\n'
                        'Para exercer seus direitos ou tirar dúvidas, entre em contato: seuemail@email.com\n',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
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
                      onPressed:
                          _acceptedTerms
                              ? () {
                                // Handle "Criar sua conta"
                                print('Criar sua conta clicked');
                              }
                              : null, // Desabilita se não aceitou os termos
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A73EC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        'Criar sua conta',
                        style: TextStyle(fontSize: 18, color: Colors.white),
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
