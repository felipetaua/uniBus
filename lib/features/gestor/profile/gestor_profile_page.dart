import 'package:bus_attendance_app/data/auth_services.dart';
import 'package:bus_attendance_app/features/onBoarding/onboarding_page.dart';
import 'package:flutter/material.dart';

class GestorProfilePage extends StatelessWidget {
  const GestorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Gestor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Informações do Perfil do Gestor'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const OnboardingPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}