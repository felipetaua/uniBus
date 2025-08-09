import 'package:bus_attendance_app/features/gestor/gestor_navigation_menu.dart';
import 'package:bus_attendance_app/features/navegation_menu.dart';
import 'package:bus_attendance_app/features/onBoarding/onboarding_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto o estado de autenticação está sendo verificado,
        // exibe um indicador de progresso. Isso evita um "flash" da tela de onboarding.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o usuário não estiver logado, direciona para a OnboardingPage.
        if (!snapshot.hasData || snapshot.data == null) {
          return const OnboardingPage();
        }

        // Se o usuário estiver logado, verifica o papel (role) no Firestore.
        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
          builder: (context, userSnapshot) {
            // Enquanto busca os dados do usuário, exibe um indicador de progresso.
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Se houver um erro ou o documento do usuário não for encontrado,
            // desloga o usuário por segurança e o envia para a OnboardingPage.
            if (userSnapshot.hasError || !userSnapshot.data!.exists) {
              FirebaseAuth.instance.signOut();
              return const OnboardingPage();
            }

            // Com os dados do usuário em mãos, verifica o papel.
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final role = userData['role'];

            // Direciona para a tela correta com base no papel.
            return role == 'gestor'
                ? const GestorNavigationMenu()
                : const NavigationMenu();
          },
        );
      },
    );
  }
}
