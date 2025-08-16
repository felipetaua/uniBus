// lib/pages/gestor_dashboard_page.dart

import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/features/gestor/dashboard/gerenciamento_grupo.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Reutilizando a classe Event do exemplo do estudante
class Event {
  final String title;
  final String date;
  final String imagePath;
  Event({required this.title, required this.date, required this.imagePath});
}

class GestorDashboardPage extends StatefulWidget {
  const GestorDashboardPage({super.key});

  @override
  State<GestorDashboardPage> createState() => _GestorDashboardPageState();
}

class _GestorDashboardPageState extends State<GestorDashboardPage> {
  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carrega dados do gestor (similar à tela de estudante)
  void _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users') // ou 'managers' se for uma coleção separada
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

    // Dados de exemplo para o dashboard do gestor
    // TODO: Substituir por dados reais do Firebase
    final int confirmedToday = 32;
    final int totalCapacity = 45;
    final List<Event> createdEvents = [
      Event(
        title: 'Feira de Ciências',
        date: '23/08/2025 às 20:30',
        imagePath: 'assets/images/events/event_feira_ciencias.png',
      ),
      Event(
        title: 'Palestra de IA',
        date: '20/11/2025 às 19:30',
        imagePath: 'assets/images/events/event_palestra.png',
      ),
    ];

    // Cores do tema
    final Color backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final Color surfaceColor =
        isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
    final Color textPrimaryColor =
        isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color onPrimaryColor =
        isDarkMode ? AppColors.darkOnPrimary : AppColors.lightOnPrimary;
    final Color primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Stack(
      children: [
        // Fundo com gradiente (mesmo estilo da tela de estudante)
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
              _buildHeader(onPrimaryColor),
              const SizedBox(height: 20),
              _buildPresenceSummaryCard(
                surfaceColor,
                textPrimaryColor,
                confirmedToday,
                totalCapacity,
              ),
              const SizedBox(height: 20),
              _buildActionsGrid(context),
              const SizedBox(height: 30),
              _buildEventsSection(
                context,
                primaryColor,
                textPrimaryColor,
                createdEvents,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Color onPrimaryColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: const AssetImage(
                  'assets/avatar/profile_placeholder.png',
                ),
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo(a),',
                    style: AppTextStyles.lightBody.copyWith(
                      color: onPrimaryColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _user?.displayName ?? 'Gestor',
                    style: AppTextStyles.lightTitle.copyWith(
                      color: onPrimaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Ícones de Ação (ex: Configurações)
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
            ),
            child: Icon(Icons.settings_outlined, color: onPrimaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPresenceSummaryCard(
    Color surfaceColor,
    Color textPrimaryColor,
    int confirmed,
    int total,
  ) {
    double percentage = total > 0 ? confirmed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        color: surfaceColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Presenças Confirmadas Hoje',
                style: AppTextStyles.lightBody.copyWith(
                  color: textPrimaryColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$confirmed',
                          style: AppTextStyles.lightTitle.copyWith(
                            fontSize: 36,
                            color: const Color(0xFF84CFB2),
                          ),
                        ),
                        TextSpan(
                          text: '/$total vagas',
                          style: AppTextStyles.lightBody.copyWith(
                            fontSize: 16,
                            color: textPrimaryColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF84CFB2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.2,
        children: [
          _ActionCard(
            icon: Icons.checklist_rtl_rounded,
            label: 'Ver Presenças',
            color: const Color(0xFF828EF3),
            onTap: () {
              // TODO: Navegar para a tela de lista de presença
            },
          ),
          _ActionCard(
            icon: Icons.group_add_outlined,
            label: 'Criar/Gerir Grupos',
            color: const Color(0xFFB687E7),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GroupManagementPage(),
                ),
              );
            },
          ),
          _ActionCard(
            icon: Icons.event_available_outlined,
            label: 'Criar Evento',
            color: const Color(0xFF84CFB2),
            onTap: () {
              // TODO: Navegar para a tela de criação de eventos
            },
          ),
          _ActionCard(
            icon: Icons.calendar_today_outlined,
            label: 'Criar Cronograma',
            color: const Color(0xFFF3C482),
            onTap: () {
              // TODO: Navegar para a tela de criação de cronograma
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection(
    BuildContext context,
    Color primaryColor,
    Color textPrimaryColor,
    List<Event> events,
  ) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seus Eventos Criados',
                style: AppTextStyles.lightTitle.copyWith(
                  color: textPrimaryColor,
                  fontSize: 20,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Ver todos',
                  style: AppTextStyles.lightBody.copyWith(color: primaryColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 250,
          child:
              events.isEmpty
                  ? Center(
                    child: Text(
                      'Nenhum evento criado ainda.',
                      style: AppTextStyles.lightBody,
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      // Pode criar um `ManagerEventCard` se precisar de ações diferentes (ex: editar)
                      return EventCard(
                        title: event.title,
                        date: event.date,
                        imagePath: event.imagePath,
                        isDarkMode: isDarkMode,
                        onConfirm:
                            () {}, // Ação para o gestor pode ser 'Editar'
                        onDecline: () {}, // Ou 'Excluir'
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

// Card de Ação para o Grid
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              Text(
                label,
                style: AppTextStyles.lightBody.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reutilizando o EventCard da tela de estudante
// Pode ser movido para um arquivo compartilhado em `lib/core/widgets/`
class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String imagePath;
  final bool isDarkMode;
  final VoidCallback onConfirm; // Para o gestor, pode ser 'Editar'
  final VoidCallback onDecline; // Para o gestor, pode ser 'Excluir'

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
            child: Text(
              title,
              style: AppTextStyles.lightBody.copyWith(
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Para o gestor, os botões podem ter outras funções
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                  onPressed: onDecline,
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppColors.lightPrimary,
                  ),
                  onPressed: onConfirm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
