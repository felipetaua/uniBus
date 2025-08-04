import 'package:bus_attendance_app/features/gestor/dashboard/gestor_dashboard_page.dart';
import 'package:bus_attendance_app/features/gestor/profile/gestor_profile_page.dart';
import 'package:bus_attendance_app/features/gestor/reports/gestor_reports_page.dart';
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
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Relatórios',
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
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const GestorDashboardPage(),
    const GestorReportsPage(),
    const GestorProfilePage(),
  ];
}