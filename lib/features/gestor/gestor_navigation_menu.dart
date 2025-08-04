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
    final Color backgroundColor =
        isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color activeColor =
        isDarkMode ? Colors.white : const Color(0xFF5A73EC);
    const Color inactiveColor = Colors.grey;

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.selectedIndex.value = 2,
        backgroundColor: const Color(0xFF5A73EC),
        shape: const CircleBorder(),
        elevation: 4.0,
        child: const Icon(Icons.dashboard, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: backgroundColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              controller: controller,
              icon: Icons.route_outlined,
              label: 'Rotas',
              index: 0,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            _buildNavItem(
              controller: controller,
              icon: Icons.groups_2_outlined,
              label: 'Presença',
              index: 1,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            const SizedBox(width: 15), // Espaço para o FAB
            _buildNavItem(
              controller: controller,
              icon: Icons.pie_chart_outline_outlined,
              label: 'Relatório',
              index: 3,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            _buildNavItem(
              controller: controller,
              icon: Icons.person_outline,
              label: 'Perfil',
              index: 4,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required GestorNavigationController controller,
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return Obx(
      () => MaterialButton(
        minWidth: 40,
        onPressed: () {
          controller.selectedIndex.value = index;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color:
                  controller.selectedIndex.value == index
                      ? activeColor
                      : inactiveColor,
            ),
            Text(
              label,
              style: TextStyle(
                color:
                    controller.selectedIndex.value == index
                        ? activeColor
                        : inactiveColor,
                fontSize: 12,
              ),
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

    const GestorDashboardPage(), // 2: dashboard inicial

    const GestorRelatoryPage(),
    const GestorProfilePage(),
  ];
}
