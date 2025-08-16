import 'dart:math';

import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({super.key});

  @override
  State<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends State<CreateRoutePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _pointControllers = [
    TextEditingController(),
  ];

  String? _selectedDriverId;
  String? _selectedBusId;

  bool _isLoading = false;

  // Função para gerar um código de convite aleatório
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<void> _saveRoute() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Usuário não autenticado.");

      final inviteCode = _generateInviteCode();
      final points =
          _pointControllers
              .where((c) => c.text.isNotEmpty)
              .map((c) => {'name': c.text, 'address': ''})
              .toList();

      await FirebaseFirestore.instance.collection('groups').add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'driver_id': _selectedDriverId,
        'bus_id': _selectedBusId,
        'points': points,
        'invite_code': inviteCode,
        'owner_id': user.uid, // Unificado para 'owner_id' para consistência
        'created_at': FieldValue.serverTimestamp(),
        'member_count': 0, // Inicializa a contagem de membros
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rota criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar rota: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addPointField() {
    setState(() {
      _pointControllers.add(TextEditingController());
    });
  }

  void _removePointField(int index) {
    setState(() {
      _pointControllers[index].dispose();
      _pointControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _pointControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textPrimaryColor =
        isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Criar Nova Rota',
          style: AppTextStyles.lightTitle.copyWith(color: textPrimaryColor),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildTextField(
              _nameController,
              'Nome da Rota',
              'Ex: Centro - Univel',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _descriptionController,
              'Descrição (Opcional)',
              'Ex: Ônibus que passa pela Av. Brasil',
              isOptional: true,
            ),
            const SizedBox(height: 24),
            _buildDropdown<String>(
              label: 'Selecionar Motorista',
              stream:
                  FirebaseFirestore.instance.collection('drivers').snapshots(),
              value: _selectedDriverId,
              onChanged: (value) => setState(() => _selectedDriverId = value),
              itemBuilder:
                  (doc) =>
                      DropdownMenuItem(value: doc.id, child: Text(doc['name'])),
              validator:
                  (value) => value == null ? 'Selecione um motorista' : null,
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              label: 'Selecionar Ônibus',
              stream:
                  FirebaseFirestore.instance.collection('buses').snapshots(),
              value: _selectedBusId,
              onChanged: (value) => setState(() => _selectedBusId = value),
              itemBuilder:
                  (doc) => DropdownMenuItem(
                    value: doc.id,
                    child: Text('${doc['model']} - ${doc['plate']}'),
                  ),
              validator:
                  (value) => value == null ? 'Selecione um ônibus' : null,
            ),
            const SizedBox(height: 24),
            Text(
              'Pontos de Parada',
              style: AppTextStyles.lightTitle.copyWith(
                fontSize: 18,
                color: textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            ..._buildPointFields(),
            TextButton.icon(
              onPressed: _addPointField,
              icon: Icon(Icons.add, color: primaryColor),
              label: Text(
                'Adicionar Ponto',
                style: TextStyle(color: primaryColor),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Salvar Rota',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (isOptional) return null;
        if (value == null || value.isEmpty) {
          return 'Este campo é obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required Stream<QuerySnapshot> stream,
    required T? value,
    required void Function(T?) onChanged,
    required DropdownMenuItem<T> Function(DocumentSnapshot) itemBuilder,
    required String? Function(T?)? validator,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Erro ao carregar dados.');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('Nenhum item encontrado em "$label".');
        }
        var items = snapshot.data!.docs.map(itemBuilder).toList();
        return DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: validator,
        );
      },
    );
  }

  List<Widget> _buildPointFields() {
    return List.generate(_pointControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _pointControllers[index],
                decoration: InputDecoration(
                  labelText: 'Nome do Ponto ${index + 1}',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome do ponto';
                  }
                  return null;
                },
              ),
            ),
            if (_pointControllers.length > 1)
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                ),
                onPressed: () => _removePointField(index),
              ),
          ],
        ),
      );
    });
  }
}
