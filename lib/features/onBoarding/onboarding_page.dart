import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bus_attendance_app/data/auth_services.dart';
import 'package:bus_attendance_app/features/auth/account_gestor.dart';
import 'package:bus_attendance_app/features/auth/account_student.dart';
import 'package:bus_attendance_app/features/onBoarding/onboarding_controller.dart';
import 'package:bus_attendance_app/features/onBoarding/onboarding_data.dart';
import 'package:bus_attendance_app/features/navegation_menu.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: Scaffold(
        body: Consumer<OnboardingController>(
          builder: (context, controller, child) {
            return Stack(
              children: [
                PageView.builder(
                  controller: controller.pageController,
                  itemCount: onboardingPages.length,
                  onPageChanged: controller.onPageChanged,
                  itemBuilder: (context, index) {
                    final page = onboardingPages[index];
                    return OnboardingPageView(
                      imagePath: page.imagePath,
                      title: page.title,
                      description: page.description,
                      buttonText: page.buttonText,
                      onButtonPressed: controller.nextPage,
                    );
                  },
                ),
                Positioned(
                  bottom: 70,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingPages.length,
                      (index) => buildDot(index, controller.currentPage),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (controller.currentPage > 0)
                        GestureDetector(
                          onTap: controller.previousPage,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200),
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap:
                              controller.currentPage ==
                                      onboardingPages.length - 1
                                  ? () => _showUserTypeModal(context)
                                  : controller.nextPage,
                          child: Container(
                            height: 45,
                            width: 210,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              onboardingPages[controller.currentPage]
                                  .buttonText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (controller.currentPage < onboardingPages.length - 1)
                        GestureDetector(
                          onTap: controller.nextPage,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200),
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildDot(int index, int currentPage) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: currentPage == index ? Colors.black : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _showUserTypeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return const _UserTypeModal();
      },
    );
  }
}

class _UserTypeModal extends StatefulWidget {
  const _UserTypeModal();

  @override
  State<_UserTypeModal> createState() => _UserTypeModalState();
}

class _UserTypeModalState extends State<_UserTypeModal> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return; // Previne múltiplos cliques

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();

      if (mounted) {
        if (user != null) {
          // Navega para a tela principal e remove todas as rotas anteriores
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const NavigationMenu()),
            (Route<dynamic> route) => false,
          );
        } else {
          // Se o usuário cancelou, não faz nada. O modal permanece aberto.
        }
      }
    } catch (e) {
      // Em caso de erro, não fecha o modal, apenas mostra a mensagem.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocorreu um erro no login: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    if (_isLoading) return;

    // Adiciona a verificação da plataforma aqui
    if (!Platform.isIOS && !Platform.isMacOS) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login com Apple está disponível apenas em dispositivos Apple.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithApple();
      if (mounted) {
        if (user != null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const NavigationMenu()),
            (Route<dynamic> route) => false,
          );
        } else {
          // Se o usuário cancelou, não faz nada, o modal permanece aberto.
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ocorreu um erro no login com Apple: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 30.0,
        right: 30.0,
        top: 30.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/logo-circle.png',
                height: 80,
                width: 80,
              ),
              const SizedBox(height: 12),
              const Text(
                'Como você quer utilizar a plataforma?',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Escolha o tipo de usuário para aproveitar tudo que podemos proporcionar na plataforma.',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder:
                                    (context) => const accountStudentPage(),
                              ),
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue como Estudante',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const accountGestorPage(),
                              ),
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue como Gestor',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Image.asset(
                          'assets/icons/google_logo.png',
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signInWithApple,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Image.asset(
                          'assets/icons/apple_logo.png',
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class OnboardingPageView extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const OnboardingPageView({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(flex: 3, child: Container()),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        // ignore: deprecated_member_use
                        color: colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
      ],
    );
  }
}
