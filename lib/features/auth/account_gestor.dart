import 'package:bus_attendance_app/features/auth/login_gestor.dart';
import 'package:bus_attendance_app/features/auth/register_gestor.dart';
import 'package:bus_attendance_app/features/onBoarding/onboarding_page.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class accountGestorPage extends StatefulWidget {
  const accountGestorPage({super.key});

  @override
  State<accountGestorPage> createState() => accountGestorPageState();
}

// ignore: camel_case_types
class accountGestorPageState extends State<accountGestorPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
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
                        colors: [Color(0x00F1F2F6), Color(0xFFF1F2F6)],
                        stops: [0, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const OnboardingPage(),
                        ),
                      );
                    },
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
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    children: [
                      _buildCarouselItem(
                        imagePath: 'assets/images/gestor-1.png',
                      ),
                      _buildCarouselItem(
                        imagePath: 'assets/images/gestor-2.png',
                      ),
                      _buildCarouselItem(
                        imagePath: 'assets/images/gestor-3.png',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => _buildDot(index)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Seja Bem-vindo, Gestor!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tenha a experiência completa com app, vamos lá.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const loginGestorPage(),
                            ),
                          );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Text(
                            'Acessar a Minha Conta',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const RegisterGestorPage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blueAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Text(
                            'Criar uma conta',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselItem({required String imagePath}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: Image.asset(imagePath, fit: BoxFit.contain, height: 330),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blueAccent : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
