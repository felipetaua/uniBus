import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Bottom Bar',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        toggleTheme: _toggleTheme,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Página Inicial', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Página da Loja', style: TextStyle(fontSize: 24))),
    const Center(
        child:
            Text('Página da Lista de Desejos', style: TextStyle(fontSize: 24))),
    const Center(
        child: Text('Página do Perfil', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cores para o tema claro
    final Color lightBackgroundColor = Colors.grey[100]!;
    final Color lightItemColor = Colors.black;
    final Color lightSelectedItemBackgroundColor = Colors.white;
    final Color lightSelectedItemBorderColor = Colors.black;

    // Cores para o tema escuro
    final Color darkBackgroundColor = Colors.grey[900]!;
    final Color darkItemColor = Colors.white;
    final Color darkSelectedItemBackgroundColor = Colors.white;
    final Color darkSelectedItemColor =
        Colors.black; // Cor do ícone/texto do item selecionado no tema escuro

    // Define as cores com base no tema atual
    final Color currentBackgroundColor =
        widget.isDarkMode ? darkBackgroundColor : lightBackgroundColor;
    final Color currentItemColor =
        widget.isDarkMode ? darkItemColor : lightItemColor;
    final Color currentSelectedItemBackgroundColor = widget.isDarkMode
        ? darkSelectedItemBackgroundColor
        : lightSelectedItemBackgroundColor;
    final Color currentSelectedItemColor = widget.isDarkMode
        ? darkSelectedItemColor
        : lightItemColor; // Cor do ícone/texto do item selecionado

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bottom Bar Animada'),
        actions: [
          IconButton(
            icon: Icon(
                widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        isDarkMode: widget.isDarkMode,
        backgroundColor: currentBackgroundColor,
        itemColor: currentItemColor,
        selectedItemBackgroundColor: currentSelectedItemBackgroundColor,
        selectedItemColor: currentSelectedItemColor,
        selectedItemBorderColor:
            lightSelectedItemBorderColor, // Usado apenas no tema claro
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isDarkMode;
  final Color backgroundColor;
  final Color itemColor;
  final Color selectedItemBackgroundColor;
  final Color selectedItemColor;
  final Color selectedItemBorderColor;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isDarkMode,
    required this.backgroundColor,
    required this.itemColor,
    required this.selectedItemBackgroundColor,
    required this.selectedItemColor,
    required this.selectedItemBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(Icons.home_outlined, 'Home', 0),
          _buildNavItem(Icons.store_outlined, 'Store', 1),
          _buildNavItem(Icons.favorite_border, 'Wishlist', 2),
          _buildNavItem(Icons.person_outline, 'Profile', 3),
          _buildNavItem(Icons. store_outlined, 'Presença', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = index == selectedIndex;
    final Duration animationDuration = const Duration(milliseconds: 300);
    final Curve animationCurve = Curves.easeInOut;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: AnimatedContainer(
        duration: animationDuration,
        curve: animationCurve,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedItemBackgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isSelected && !isDarkMode
              ? Border.all(color: selectedItemBorderColor, width: 1.5)
              : null, // Borda apenas no tema claro para o item selecionado
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: isSelected ? selectedItemColor : itemColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedItemColor : itemColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
