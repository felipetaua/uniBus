import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:bus_attendance_app/features/groups/gerenciamento_grupo.dart'; // Importe o modelo de dados
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCreationPage extends StatefulWidget {
  const EventCreationPage({super.key});

  @override
  State<EventCreationPage> createState() => _EventCreationPageState();
}

const List<String> _eventAssetImages = [
  'assets/images/events/conferencia.jpg',
  'assets/images/events/congresso.jpg',
  'assets/images/events/debate.jpg',
  'assets/images/events/defesa_tese.jpg',
  'assets/images/events/formatura.jpg',
  'assets/images/events/hackathon.jpg',
  'assets/images/events/palestra.jpg',
  'assets/images/events/seminário.jpg',
  'assets/images/events/visita-tecnica.png',
  'assets/images/events/workshop.jpg',
  'assets/images/events/apresent.png',
  'assets/images/events/feira.png',
];

class _EventCreationPageState extends State<EventCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Group> _managedGroups = [];
  Group? _selectedGroup;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedAssetPath; // Armazena o caminho da imagem selecionada
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchManagedGroups();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchManagedGroups() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('groups')
              .where('owner_id', isEqualTo: user.uid)
              .get();
      final groups =
          snapshot.docs.map((doc) => Group.fromFirestore(doc)).toList();
      if (mounted) {
        setState(() {
          _managedGroups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Função para abrir o seletor de imagens
  Future<void> _selectLocalImage() async {
    final selectedImage = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _eventAssetImages.length,
            itemBuilder: (context, index) {
              final imagePath = _eventAssetImages[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(imagePath),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              );
            },
          ),
        );
      },
    );

    if (selectedImage != null) {
      setState(() {
        _selectedAssetPath = selectedImage;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate() ||
        _selectedGroup == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);

    try {
      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': _selectedAssetPath, // Salva o caminho do asset
        'date': Timestamp.fromDate(eventDateTime),
        'groupId': _selectedGroup!.id,
        'ownerId': FirebaseAuth.instance.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar evento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
    final Color onPrimaryColor =
        isDarkMode ? AppColors.darkOnPrimary : AppColors.lightOnPrimary;
    final Color primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

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
                colors: [Color(0xFF84CFB2), Color(0xFFCAFF5C)],
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
                    titlePadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    title: Text(
                      'Criar Novo Evento',
                      style: AppTextStyles.lightTitle.copyWith(
                        color: onPrimaryColor,
                        fontSize: 22,
                      ),
                    ),
                    centerTitle: false,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePicker(surfaceColor, textPrimaryColor),
                          const SizedBox(height: 24),
                          _buildGroupSelector(surfaceColor, textPrimaryColor),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titleController,
                            style: TextStyle(color: textPrimaryColor),
                            decoration: const InputDecoration(
                              labelText: 'Título do Evento',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty ? 'Campo obrigatório' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            style: TextStyle(color: textPrimaryColor),
                            decoration: const InputDecoration(
                              labelText: 'Descrição',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 4,
                            validator:
                                (value) =>
                                    value!.isEmpty ? 'Campo obrigatório' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildDateTimePicker(
                            surfaceColor,
                            textPrimaryColor,
                            primaryColor,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _createEvent,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child:
                                _isSaving
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text('Criar Evento'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(Color surfaceColor, Color textPrimaryColor) {
    return Center(
      child: GestureDetector(
        onTap: _selectLocalImage,
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            image:
                _selectedAssetPath != null
                    ? DecorationImage(
                      image: AssetImage(_selectedAssetPath!),
                      fit: BoxFit.cover,
                    )
                    : null,
          ),
          child:
              _selectedAssetPath == null
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_search, // Ícone mais apropriado
                        color: textPrimaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecionar Imagem',
                        style: TextStyle(
                          color: textPrimaryColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  )
                  : null,
        ),
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
          items:
              _managedGroups.map((Group group) {
                return DropdownMenuItem<Group>(
                  value: group,
                  child: Text(
                    group.name,
                    style: TextStyle(color: textPrimaryColor),
                  ),
                );
              }).toList(),
          onChanged: (Group? newValue) {
            setState(() {
              _selectedGroup = newValue;
            });
          },
          validator: (value) => value == null ? 'Campo obrigatório' : null,
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(
    Color surfaceColor,
    Color textPrimaryColor,
    Color primaryColor,
  ) {
    return Card(
      color: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectDate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data',
                      style: TextStyle(
                        color: textPrimaryColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDate == null
                          ? 'Selecionar'
                          : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      style: AppTextStyles.lightBody.copyWith(
                        color: textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8, height: 40, child: VerticalDivider()),
            Expanded(
              child: InkWell(
                onTap: _selectTime,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hora',
                      style: TextStyle(
                        color: textPrimaryColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedTime == null
                          ? 'Selecionar'
                          : _selectedTime!.format(context),
                      style: AppTextStyles.lightBody.copyWith(
                        color: textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
