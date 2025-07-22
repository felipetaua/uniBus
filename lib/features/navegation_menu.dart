// lib/navigation_menu.dart

import 'package:bus_attendance_app/features/estudante/historico/historico_page.dart';
import 'package:bus_attendance_app/features/estudante/home/estudante_home.dart';
import 'package:bus_attendance_app/features/estudante/loja/store_page.dart';
import 'package:bus_attendance_app/features/estudante/perfil/profile_page.dart';
import 'package:bus_attendance_app/features/estudante/rotas/rotes_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkmode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // A barra de navegação que você criou
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected:
              (index) => controller.selectedIndex.value = index,
          backgroundColor: darkmode ? Colors.black : Colors.white,
          indicatorColor:
              darkmode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.route_sharp),
              label: 'Rotas',
            ),
            NavigationDestination(
              icon: Icon(Icons.store_outlined),
              label: 'Store',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Presença',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline_rounded),
              label: 'Histórico',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
      // Exibe a tela correspondente ao item selecionado
      body: Obx(
        () => controller.screen[controller.selectedIndex.value] as Widget,
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  // Lista de telas que serão exibidas pela NavigationMenu
  final screen = [
    const RotesPage(), // 1: Tela de Rotas
    const StorePage(), // 2: Tela da Loja

    const StudentHomePage(), // 3: Tela Home / presença

    const HistoryPage(), // 4: Tela de Wishlist (Exemplo)
    const ProfilePage(), // 5: Tela de Perfil
  ];
}
