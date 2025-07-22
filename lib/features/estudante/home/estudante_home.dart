// lib/pages/student_home_page.dart

import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final Color primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final Color surfaceColor =
        isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
    final Color textPrimaryColor =
        isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color textSecondaryColor =
        isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final Color onPrimaryColor =
        isDarkMode ? AppColors.darkOnPrimary : AppColors.lightOnPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFB06DF9),
                  Color(0xFF828EF3),
                  Color(0xFF84CFB2),
                  Color(0xFFCAFF5C),
                ],
                stops: [0.0, 0.33, 0.66, 1.0],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [backgroundColor.withOpacity(0.0), backgroundColor],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),
          // Conteúdo principal
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Perfil, Moedas, XP, Ícones)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 60.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Perfil do usuário
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: const AssetImage(
                              'assets/avatar/profile_placeholder.png',
                            ), // Imagem de perfil
                            backgroundColor: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wilson Junior',
                                style: AppTextStyles.lightBody.copyWith(
                                  color: onPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  // Moedas
                                  Image.asset(
                                    'assets/icons/coin_icon.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '9999',
                                    style: AppTextStyles.lightBody.copyWith(
                                      color: onPrimaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Experiência (XP)
                                  Image.asset(
                                    'assets/icons/xp_icon.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '9999 XP',
                                    style: AppTextStyles.lightBody.copyWith(
                                      color: onPrimaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Ícones de ação (QR e Notificações)
                      Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              color: onPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            child: Icon(
                              Icons.notifications_none,
                              color: onPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Barra de pesquisa
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      style: TextStyle(color: textPrimaryColor),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: textSecondaryColor),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: textSecondaryColor),
                        suffixIcon: Icon(
                          Icons.filter_list,
                          color: textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Card de informações do ônibus
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Card(
                    color: surfaceColor,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: primaryColor),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sexta-feira, 18/07/2025',
                                style: AppTextStyles.lightTitle.copyWith(
                                  fontSize: 18,
                                  color: textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Ônibus das 17h',
                                style: AppTextStyles.lightBody.copyWith(
                                  color: textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Seção "Você vai hoje?"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      'Você vai hoje?',
                      style: AppTextStyles.lightTitle.copyWith(
                        color: textPrimaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Botões de confirmação de presença
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Lógica para "Vou hoje"
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Vou hoje',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF84CFB2,
                            ), // Verde-água
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Lógica para "Não vou"
                          },
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Não vou',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD600), // Amarelo
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Lógica para "Escanear para confirmar"
                    },
                    icon: Icon(Icons.qr_code, color: primaryColor),
                    label: Text(
                      'Escanear para confirmar',
                      style: TextStyle(color: primaryColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      minimumSize: const Size(
                        double.infinity,
                        0,
                      ), // Ocupa a largura total
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Seção "Eventos acadêmicos"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Eventos acadêmicos',
                        style: AppTextStyles.lightTitle.copyWith(
                          color: textPrimaryColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Lógica para "Ver mais" eventos
                        },
                        child: Text(
                          'Ver mais',
                          style: AppTextStyles.lightBody.copyWith(
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Lista de eventos acadêmicos (Horizontal Scroll)
                SizedBox(
                  height: 200, // Altura fixa para o carrossel de eventos
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    itemCount: 3, // Exemplo: 3 eventos
                    itemBuilder: (context, index) {
                      return EventCard(
                        title: index == 0 ? 'Palestra' : 'Feira de Ciências',
                        date:
                            index == 0
                                ? '20/11/2025 às 19:30'
                                : '23/08/2025 às 20:30',
                        imagePath:
                            index == 0
                                ? 'assets/images/event_palestra.png' // Imagem para Palestra
                                : 'assets/images/event_feira_ciencias.png', // Imagem para Feira de Ciências
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 80), // Espaço para a BottomNavigationBar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type:
            BottomNavigationBarType
                .fixed, // Garante que todos os itens são visíveis
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        currentIndex: 2, // Exemplo: Presença selecionada
        onTap: (index) {
          // Lógica de navegação para cada item
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Rotas'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Loja'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Presença',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String imagePath;
  final bool isDarkMode;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.imagePath,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor =
        isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
    final Color onSurfaceColor =
        isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;

    return Container(
      width: 180, // Largura do card de evento
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(15.0),
            ),
            child: Image.asset(
              imagePath,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.lightBody.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onSurfaceColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  date,
                  style: AppTextStyles.lightBody.copyWith(
                    fontSize: 12,
                    color:
                        isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.lightSecondary,
                    ), // Ícone de confirmar
                    SizedBox(width: 5),
                    Icon(
                      Icons.cancel_outlined,
                      color: AppColors.lightError,
                    ), // Ícone de cancelar
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
