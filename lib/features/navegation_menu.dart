import 'package:bus_attendance_app/features/estudante/home/estudante_home.dart';
import 'package:bus_attendance_app/features/estudante/loja/store_page.dart';
import 'package:bus_attendance_app/features/estudante/perfil/profile_page.dart';
import 'package:bus_attendance_app/features/estudante/rotas/rotes_page.dart';
import 'package:bus_attendance_app/features/estudante/message/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor =
        isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color activeColor =
        isDarkMode ? Colors.white : const Color(0xFF888AF4);
    const Color inactiveColor = Colors.grey;

    return Scaffold(
      // Usar IndexedStack preserva o estado de cada tela ao navegar
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: controller.screen.map((widget) => widget).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.selectedIndex.value = 2,
        backgroundColor: const Color(0xFF84CFB2),
        shape: const CircleBorder(),
        elevation: 4.0,
        child: const Icon(Icons.check_box_outlined, color: Colors.white),
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
              icon: Icons.route_sharp,
              label: 'Rotas',
              index: 0,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            _buildNavItem(
              controller: controller,
              icon: Icons.shopping_bag_outlined,
              label: 'Loja',
              index: 1,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            const SizedBox(width: 30), // Espaço para o FAB
            _buildNavItem(
              controller: controller,
              icon: Icons.wysiwyg_rounded,
              label: 'Mensagens',
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
    required NavigationController controller,
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

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 2.obs; // Inicia na tela de Presença (Home)

  // Lista de telas que serão exibidas pela NavigationMenu
  final screen = [
    const RoutesPage(), // 1: Tela de Rotas
    const StorePage(), // 2: Tela da Loja

    const StudentHomePage(), // 3: Tela Home / presença

    const MessagePage(), // 4: Tela de message (Exemplo)
    const ProfilePage(), // 5: Tela de Perfil
  ];
}
