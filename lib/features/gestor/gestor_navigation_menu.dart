import 'package:bus_attendance_app/features/gestor/dashboard/dashboard_gestor.dart';
import 'package:bus_attendance_app/features/gestor/presence/presence_screen.dart';
import 'package:bus_attendance_app/features/gestor/profile/gestor_profile_page.dart';
import 'package:bus_attendance_app/features/gestor/relatorios/relatory_screen.dart';
import 'package:bus_attendance_app/features/gestor/rotas/rotes_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GestorNavigationMenu extends StatelessWidget {
  const GestorNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GestorNavigationController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor =
        isDarkMode ? Colors.white : const Color(0xFF5A73EC);
    const Color inactiveColor = Colors.grey;

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex.value,
          onTap: (index) => controller.selectedIndex.value = index,
          selectedItemColor: activeColor,
          unselectedItemColor: inactiveColor,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.route_outlined),
              activeIcon: Icon(Icons.route_sharp),
              label: 'Rotas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_2_outlined),
              activeIcon: Icon(Icons.groups_2),
              label: 'Presença',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline_outlined),
              activeIcon: Icon(Icons.pie_chart_rounded),
              label: 'Relátorio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class GestorNavigationController extends GetxController {
  final Rx<int> selectedIndex = 2.obs;

  final screens = [
    const RotesPages(),
    const PresenceStudentsScreen(),

    const GestorDashboardPage(), // dashboard inicial

    const GestorRelatoryPage(),
    const GestorProfilePage(),
  ];
}
