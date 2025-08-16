import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:bus_attendance_app/features/groups/vincular_grupo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

      if (mounted) {
        setState(() {
          _userData = userDoc.data();
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final Color primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final Color textPrimaryColor =
        isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color textSecondaryColor =
        isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final bool hasGroup = _userData != null && _userData?['group_id'] != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notificações',
          style: AppTextStyles.lightTitle.copyWith(color: textPrimaryColor),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      backgroundColor: backgroundColor,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasGroup
              ? _buildNotificationsList(textPrimaryColor, textSecondaryColor)
              : _buildNoGroupIndicator(
                primaryColor,
                textPrimaryColor,
                textSecondaryColor,
              ),
    );
  }

  // Dentro da classe _NotificacoesPageState em NotificacoesPage.dart

  // ... (resto do seu código)

  Widget _buildNoGroupIndicator(
    Color primaryColor,
    Color textPrimaryColor,
    Color textSecondaryColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add_outlined, size: 80, color: primaryColor),
            const SizedBox(height: 20),
            Text(
              'Vincule-se a um grupo',
              textAlign: TextAlign.center,
              style: AppTextStyles.lightTitle.copyWith(
                fontSize: 22,
                color: textPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Para receber notificações e ver as novidades, você precisa fazer parte de um grupo.',
              textAlign: TextAlign.center,
              style: AppTextStyles.lightBody.copyWith(
                color: textSecondaryColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30), // Espaçamento para o botão
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white, // Cor do texto e ícone
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                // Ação para navegar para a nova tela de vinculação
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const VincularGrupoPage(),
                  ),
                );
              },
              child: Text(
                'Procurar um Grupo',
                style: AppTextStyles.lightBody.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (resto do seu código)

  Widget _buildNotificationsList(
    Color textPrimaryColor,
    Color textSecondaryColor,
  ) {
    // Dados de exemplo
    final List<Map<String, String>> notifications = [
      {
        'title': 'Presença confirmada!',
        'subtitle': 'Sua presença para o dia 25/10 foi confirmada com sucesso.',
        'time': '2h atrás',
      },
    ];

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF84CFB2),
            child: Icon(Icons.check, color: Colors.white),
          ),
          title: Text(
            notification['title']!,
            style: AppTextStyles.lightBody.copyWith(
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
          subtitle: Text(
            notification['subtitle']!,
            style: AppTextStyles.lightBody.copyWith(color: textSecondaryColor),
          ),
          trailing: Text(
            notification['time']!,
            style: TextStyle(color: textSecondaryColor, fontSize: 12),
          ),
        );
      },
    );
  }
}
