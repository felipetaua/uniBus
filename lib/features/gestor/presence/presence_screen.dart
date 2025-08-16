// lib/features/gestor/presence/presence_students_screen.dart

import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

// Modelo de dados para representar um estudante na lista
class StudentPresence {
  final String name;
  final String avatarUrl;
  final String pickupPoint;
  final PresenceStatus status;

  StudentPresence({
    required this.name,
    required this.avatarUrl,
    required this.pickupPoint,
    required this.status,
  });
}

// Enum para o status da presença
enum PresenceStatus { confirmed, absent, pending }

class PresenceStudentsScreen extends StatefulWidget {
  const PresenceStudentsScreen({super.key});

  @override
  State<PresenceStudentsScreen> createState() => _PresenceStudentsScreenState();
}

class _PresenceStudentsScreenState extends State<PresenceStudentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TODO: Substituir estes dados mockados por uma chamada ao Firebase
  final List<StudentPresence> _allStudents = [
    StudentPresence(
      name: 'Ana Júlia',
      avatarUrl: 'https://i.pravatar.cc/150?u=1',
      pickupPoint: 'Ponto A - Centro',
      status: PresenceStatus.confirmed,
    ),
    StudentPresence(
      name: 'Bruno Silva',
      avatarUrl: 'https://i.pravatar.cc/150?u=2',
      pickupPoint: 'Ponto B - Bairro Novo',
      status: PresenceStatus.confirmed,
    ),
    StudentPresence(
      name: 'Carla Dias',
      avatarUrl: 'https://i.pravatar.cc/150?u=3',
      pickupPoint: 'Ponto C - Praça',
      status: PresenceStatus.absent,
    ),
    StudentPresence(
      name: 'Daniel Oliveira',
      avatarUrl: 'https://i.pravatar.cc/150?u=4',
      pickupPoint: 'Ponto A - Centro',
      status: PresenceStatus.confirmed,
    ),
    StudentPresence(
      name: 'Eduarda Costa',
      avatarUrl: 'https://i.pravatar.cc/150?u=5',
      pickupPoint: 'Ponto D - Rodoviária',
      status: PresenceStatus.pending,
    ),
    StudentPresence(
      name: 'Felipe Rocha',
      avatarUrl: 'https://i.pravatar.cc/150?u=6',
      pickupPoint: 'Ponto B - Bairro Novo',
      status: PresenceStatus.confirmed,
    ),
    StudentPresence(
      name: 'Gabriela Lima',
      avatarUrl: 'https://i.pravatar.cc/150?u=7',
      pickupPoint: 'Ponto C - Praça',
      status: PresenceStatus.absent,
    ),
    StudentPresence(
      name: 'Heitor Martins',
      avatarUrl: 'https://i.pravatar.cc/150?u=8',
      pickupPoint: 'Ponto A - Centro',
      status: PresenceStatus.pending,
    ),
  ];

  List<StudentPresence> _filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredStudents = _allStudents;
    _searchController.addListener(_filterStudents);
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents =
          _allStudents.where((student) {
            return student.name.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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

    final confirmedCount =
        _allStudents.where((s) => s.status == PresenceStatus.confirmed).length;
    final absentCount =
        _allStudents.where((s) => s.status == PresenceStatus.absent).length;
    final pendingCount =
        _allStudents.where((s) => s.status == PresenceStatus.pending).length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Lista de Presença',
          style: AppTextStyles.lightTitle.copyWith(color: textPrimaryColor),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildSummaryCards(confirmedCount, absentCount, pendingCount),
                  _buildSearchBar(surfaceColor, textSecondaryColor),
                ],
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: primaryColor,
                  unselectedLabelColor: textSecondaryColor,
                  indicatorColor: primaryColor,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Confirmados'),
                    Tab(text: 'Ausentes'),
                    Tab(text: 'Pendentes'),
                  ],
                ),
                backgroundColor,
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildStudentList(
              PresenceStatus.confirmed,
              surfaceColor,
              textPrimaryColor,
              textSecondaryColor,
            ),
            _buildStudentList(
              PresenceStatus.absent,
              surfaceColor,
              textPrimaryColor,
              textSecondaryColor,
            ),
            _buildStudentList(
              PresenceStatus.pending,
              surfaceColor,
              textPrimaryColor,
              textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(int confirmed, int absent, int pending) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SummaryCard(
            count: confirmed,
            label: 'Confirmados',
            color: const Color(0xFF84CFB2),
          ),
          _SummaryCard(
            count: absent,
            label: 'Ausentes',
            color: const Color(0xFFB687E7),
          ),
          _SummaryCard(
            count: pending,
            label: 'Pendentes',
            color: const Color(0xFFF3C482),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color surfaceColor, Color textSecondaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Pesquisar estudante...',
          hintStyle: TextStyle(color: textSecondaryColor),
          prefixIcon: Icon(Icons.search, color: textSecondaryColor),
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList(
    PresenceStatus status,
    Color surfaceColor,
    Color textPrimaryColor,
    Color textSecondaryColor,
  ) {
    final students =
        _filteredStudents.where((s) => s.status == status).toList();

    if (students.isEmpty) {
      return Center(
        child: Text(
          'Nenhum estudante nesta categoria.',
          style: AppTextStyles.lightBody.copyWith(color: textSecondaryColor),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          elevation: 2,
          color: surfaceColor,
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(student.avatarUrl),
              radius: 25,
            ),
            title: Text(
              student.name,
              style: AppTextStyles.lightBody.copyWith(
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            subtitle: Text(
              student.pickupPoint,
              style: AppTextStyles.lightBody.copyWith(
                fontSize: 14,
                color: textSecondaryColor,
              ),
            ),
            trailing: Icon(Icons.more_vert, color: textSecondaryColor),
          ),
        );
      },
    );
  }
}

// Widget auxiliar para os cards de resumo
class _SummaryCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: AppTextStyles.lightTitle.copyWith(
                color: color,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.lightBody.copyWith(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Delegate para fixar a TabBar no topo ao rolar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.backgroundColor);

  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
