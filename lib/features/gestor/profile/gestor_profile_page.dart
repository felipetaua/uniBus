import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:bus_attendance_app/data/auth_services.dart';
import 'package:bus_attendance_app/features/onBoarding/onboarding_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GestorProfilePage extends StatefulWidget {
  const GestorProfilePage({super.key});

  @override
  State<GestorProfilePage> createState() => _GestorProfilePageState();
}

class _GestorProfilePageState extends State<GestorProfilePage> {
  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carrega os dados do gestor logado
  void _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Assumindo que os gestores também estão na coleção 'users'
      // ou mude para a coleção correta, ex: 'managers'
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

      if (mounted) {
        setState(() {
          _user = currentUser;
          _userData = userDoc.data();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final Color backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final Color surfaceColor =
        isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
    final Color textPrimaryColor =
        isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color textSecondaryColor =
        isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final Color primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Meu Perfil',
          style: AppTextStyles.lightTitle.copyWith(color: textPrimaryColor),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      body:
          _user == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  _buildHeader(textPrimaryColor, textSecondaryColor),
                  const SizedBox(height: 24),
                  _buildInfoCard(surfaceColor, textPrimaryColor),
                  const SizedBox(height: 24),
                  _buildMenuList(surfaceColor, textPrimaryColor, primaryColor),
                ],
              ),
    );
  }

  Widget _buildHeader(Color textPrimaryColor, Color textSecondaryColor) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage:
              _user?.photoURL != null
                  ? NetworkImage(_user!.photoURL!)
                  : const AssetImage('assets/avatar/profile_placeholder.png')
                      as ImageProvider,
          backgroundColor: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        Text(
          _user?.displayName ?? 'Nome do Gestor',
          style: AppTextStyles.lightTitle.copyWith(
            fontSize: 22,
            color: textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _user?.email ?? 'email@gestor.com',
          style: AppTextStyles.lightBody.copyWith(color: textSecondaryColor),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Color surfaceColor, Color textPrimaryColor) {
    return Card(
      color: surfaceColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem('Rotas', '2', textPrimaryColor),
            _buildInfoItem('Ônibus', '3', textPrimaryColor),
            _buildInfoItem('Motoristas', '3', textPrimaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.lightTitle.copyWith(fontSize: 20, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.lightBody.copyWith(
            color: color.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuList(
    Color surfaceColor,
    Color textPrimaryColor,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.settings_outlined,
            title: 'Configurações da Conta',
            onTap: () {},
            color: textPrimaryColor,
          ),
          const Divider(height: 1),
          _buildMenuTile(
            icon: Icons.help_outline,
            title: 'Ajuda e Suporte',
            onTap: () {},
            color: textPrimaryColor,
          ),
          const Divider(height: 1),
          _buildMenuTile(
            icon: Icons.logout,
            title: 'Sair',
            color: Colors.red,
            onTap: () async {
              await AuthService().signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const OnboardingPage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: AppTextStyles.lightBody.copyWith(color: color)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: color.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }
}
