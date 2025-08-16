import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:bus_attendance_app/features/groups/gerenciamento_grupo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScheduleCreationPage extends StatefulWidget {
  const ScheduleCreationPage({super.key});

  @override
  State<ScheduleCreationPage> createState() => _ScheduleCreationPageState();
}

class _ScheduleCreationPageState extends State<ScheduleCreationPage> {
  List<Group> _managedGroups = [];
  Group? _selectedGroup;
  List<bool> _selectedDays = List.filled(7, false); // Seg, Ter, Qua, Qui, Sex, Sab, Dom
  bool _isLoading = true;

  final List<String> _weekDays = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    _fetchManagedGroups();
  }

  Future<void> _fetchManagedGroups() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('owner_id', isEqualTo: user.uid)
          .get();
      
      final groups = snapshot.docs.map((doc) => Group.fromFirestore(doc)).toList();
      setState(() {
        _managedGroups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Tratar erro
    }
  }

  Future<void> _fetchGroupSchedule(Group group) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('groups').doc(group.id).get();
      final data = doc.data();
      if (data != null && data.containsKey('active_days')) {
        final List<dynamic> activeDaysFromDb = data['active_days'];
        setState(() {
          _selectedDays = List.generate(7, (index) => activeDaysFromDb.contains(index + 1));
        });
      } else {
        setState(() {
          _selectedDays = List.filled(7, false);
        });
      }
    } catch (e) {
      // Tratar erro
    }
  }

  Future<void> _saveSchedule() async {
    if (_selectedGroup == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um grupo primeiro.')),
      );
      return;
    }

    final List<int> activeDays = [];
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) {
        activeDays.add(i + 1); // 1 para Segunda, 2 para Terça, etc.
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(_selectedGroup!.id)
          .update({'active_days': activeDays});
      
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cronograma salvo com sucesso!')),
        );
      }
    } catch(e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar o cronograma: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final Color backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final Color surfaceColor = isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
    final Color textPrimaryColor = isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color onPrimaryColor = isDarkMode ? AppColors.darkOnPrimary : AppColors.lightOnPrimary;
     final Color primaryColor = isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Fundo com gradiente
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF3C482), Color(0xFFCAFF5C)],
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
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: onPrimaryColor,
                  elevation: 0,
                  pinned: true,
                  expandedHeight: 120,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    title: Text(
                      'Definir Cronograma',
                      style: AppTextStyles.lightTitle.copyWith(color: onPrimaryColor, fontSize: 22),
                    ),
                    centerTitle: false,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGroupSelector(surfaceColor, textPrimaryColor),
                        const SizedBox(height: 24),
                        Text(
                          'Dias da Semana Ativos',
                           style: AppTextStyles.lightTitle.copyWith(fontSize: 18, color: textPrimaryColor),
                        ),
                        const SizedBox(height: 8),
                         Text(
                          'Selecione os dias em que o ônibus desta rota estará disponível para os estudantes marcarem presença.',
                           style: AppTextStyles.lightBody.copyWith(color: textPrimaryColor.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 16),
                        _buildWeekDaysSelector(surfaceColor, primaryColor),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _saveSchedule,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Salvar Cronograma'),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSelector(Color surfaceColor, Color textPrimaryColor) {
    return Card(
      color: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: DropdownButtonFormField<Group>(
          value: _selectedGroup,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Selecione um Grupo',
            border: InputBorder.none,
          ),
          items: _managedGroups.map((Group group) {
            return DropdownMenuItem<Group>(
              value: group,
              child: Text(group.name, style: TextStyle(color: textPrimaryColor)),
            );
          }).toList(),
          onChanged: (Group? newValue) {
            setState(() {
              _selectedGroup = newValue;
              if (newValue != null) {
                _fetchGroupSchedule(newValue);
              }
            });
          },
          validator: (value) => value == null ? 'Campo obrigatório' : null,
        ),
      ),
    );
  }

  Widget _buildWeekDaysSelector(Color surfaceColor, Color primaryColor) {
    if (_selectedGroup == null) {
      return const Center(child: Text('Selecione um grupo para ver o cronograma.'));
    }
    
    return Card(
      color: surfaceColor,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: List<Widget>.generate(7, (int index) {
            return FilterChip(
              label: Text(_weekDays[index]),
              selected: _selectedDays[index],
              onSelected: (bool selected) {
                setState(() {
                  _selectedDays[index] = selected;
                });
              },
              selectedColor: primaryColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: _selectedDays[index] ? Colors.white : null,
              ),
            );
          }),
        ),
      ),
    );
  }
}
