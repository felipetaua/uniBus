// lib/pages/student_home_page.dart

import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:bus_attendance_app/features/estudante/home/notificacoes_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Event {
  final String title;
  final String date;
  final String imagePath;

  Event({required this.title, required this.date, required this.imagePath});
}

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  User? _user;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _groupData;
  bool _isBusDayToday = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final userData = userDoc.data();
      final groupId = userData?['group_id'];
      Map<String, dynamic>? groupData;
      bool isBusDayToday = false;

      if (groupId != null) {
        final groupDoc = await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .get();

        if (groupDoc.exists) {
          groupData = groupDoc.data();
          final List<dynamic> activeDays = groupData?['active_days'] ?? [];
          final int todayWeekday = DateTime.now().weekday;
          isBusDayToday = activeDays.contains(todayWeekday);
        }
      }

      if (mounted) {
        setState(() {
          _user = currentUser;
          _userData = userData;
          _groupData = groupData;
          _isBusDayToday = isBusDayToday;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    // Lista de eventos - pode ser carregada de um banco de dados no futuro
    final List<Event> academicEvents = [
      Event(
        title: 'Palestra de IA',
        date: '20/11/2025 às 19:30',
        imagePath: 'assets/images/events/event_palestra.png',
      ),
      Event(
        title: 'Feira de Ciências',
        date: '23/08/2025 às 20:30',
        imagePath: 'assets/images/events/event_feira_ciencias.png',
      ),
      Event(
        title: 'Maratona de Programação',
        date: '05/12/2025 às 09:00',
        imagePath:
            'assets/images/events/event_palestra.png', // Exemplo com imagem reutilizada
      ),
    ];

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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Verifica se o usuário está vinculado a um grupo
    final bool hasGroup = _userData != null && _userData?['group_id'] != null;

    return Stack(
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
                              _user?.displayName ?? 'Carregando...',
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
                                  _userData != null
                                      ? (_userData!['coins'] ?? 0).toString()
                                      : '...',
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
                                  _userData != null
                                      ? '${_userData!['xp'] ?? 0} XP'
                                      : '...',
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
                            Icons.history_outlined,
                            color: onPrimaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificacoesPage(),
                              ),
                            );
                          },
                          child: Container(
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
                child: Material(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(30.0),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
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
                    child:
                        hasGroup
                            ? Row(
                              children: [
                                Icon(Icons.calendar_today, color: primaryColor),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      toBeginningOfSentenceCase(DateFormat(
                                        "EEEE, dd 'de' MMMM",
                                        "pt_BR",
                                      ).format(DateTime.now()))!,
                                      style: AppTextStyles.lightTitle.copyWith(
                                        fontSize: 18,
                                        color: textPrimaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _groupData?['name'] ?? 'Ônibus',
                                      style: AppTextStyles.lightBody.copyWith(
                                        color: textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                            : Row(
                              children: [
                                Icon(
                                  Icons.group_add_outlined,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vincule-se a um grupo',
                                        style: AppTextStyles.lightTitle
                                            .copyWith(
                                              fontSize: 18,
                                              color: textPrimaryColor,
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Peça o código ao organizador para ver as informações do ônibus.',
                                        style: AppTextStyles.lightBody.copyWith(
                                          color: textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Seção "Você vai hoje?"
              if (hasGroup && _isBusDayToday) ...[
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
                            backgroundColor: const Color(0xFFB687E7),
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
              ],
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
                        fontSize: 20,
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
                height: 250, // Altura fixa para o carrossel de eventos
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  itemCount: academicEvents.length,
                  itemBuilder: (context, index) {
                    final event = academicEvents[index];
                    return EventCard(
                      title: event.title,
                      date: event.date,
                      imagePath: event.imagePath,
                      isDarkMode: isDarkMode,
                      onConfirm: () {
                        // TODO: Adicionar lógica para confirmar presença no evento
                      },
                      onDecline: () {
                        // TODO: Adicionar lógica para recusar presença no evento
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String imagePath;
  final bool isDarkMode;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.imagePath,
    required this.isDarkMode,
    required this.onConfirm,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor =
        isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
    final Color textPrimaryColor =
        isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color textSecondaryColor =
        isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16.0),
            ),
            child: Image.asset(
              imagePath,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.lightBody.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: AppTextStyles.lightBody.copyWith(
                    fontSize: 12,
                    color: textSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDecline,
                  child: Text(
                    'Recusar',
                    style: TextStyle(color: textSecondaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF84CFB2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
