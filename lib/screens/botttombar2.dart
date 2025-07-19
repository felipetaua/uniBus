import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'student_dashboard.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkmode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          backgroundColor: darkmode ? Colors.black : Colors.white,
          indicatorColor: darkmode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.store), label: 'Store'),
            NavigationDestination(
                icon: Icon(Icons.favorite), label: 'Wishlist'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
      body: Obx(() => controller.screen[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  // no lugar do container vai a pagina
  final screen = [
    StudentDashboard(), // Aqui você coloca sua tela principal do estudante
    Container(
      color: Colors.blue,
    ),
    Container(
      color: Colors.deepPurple,
    ),
    Container(
      color: Colors.orange,
    ),
  ];
}
