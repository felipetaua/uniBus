// lib/features/group/vincular_grupo_page.dart

import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VincularGrupoPage extends StatefulWidget {
  const VincularGrupoPage({super.key});

  @override
  State<VincularGrupoPage> createState() => _VincularGrupoPageState();
}

class _VincularGrupoPageState extends State<VincularGrupoPage> {
  final TextEditingController _codeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _groupData;
  String? _groupId;
  List<Map<String, dynamic>> _groupMembers = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _findGroup() async {
    if (_codeController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _groupData = null;
    });

    try {
      final querySnapshot =
          await _firestore
              .collection(
                'groups',
              ) // Assumindo que sua coleção se chama 'groups'
              .where('invite_code', isEqualTo: _codeController.text.trim())
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final groupDoc = querySnapshot.docs.first;
        _groupData = groupDoc.data();
        _groupId = groupDoc.id;

        // Buscar alguns membros para exibir (ex: os 10 primeiros)
        final membersSnapshot =
            await _firestore
                .collection('users')
                .where('group_id', isEqualTo: _groupId)
                .limit(10)
                .get();

        _groupMembers =
            membersSnapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] =
                  doc.id; // Adiciona o ID do documento para usar como chave única
              return data;
            }).toList();
      } else {
        _errorMessage = 'Nenhum grupo encontrado com este código.';
      }
    } catch (e) {
      _errorMessage = 'Ocorreu um erro ao buscar o grupo.';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _joinGroup() async {
    if (_groupId == null || _auth.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userRef = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid);
      final newGroupRef = _firestore.collection('groups').doc(_groupId!);

      // Usar uma transação para garantir a consistência dos contadores
      await _firestore.runTransaction((transaction) async {
      
        // --- LEITURAS PRIMEIRO ---
        // 1. Pega o estado atual do usuário
        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw Exception("Documento do usuário não encontrado.");
        }

        // 2. Pega o estado do novo grupo para garantir que ele existe
        final newGroupSnapshot = await transaction.get(newGroupRef);
        if (!newGroupSnapshot.exists) {
          throw Exception(
            "O grupo que você está tentando entrar não existe mais.",
          );
        }

        final oldGroupId = userSnapshot.data()?['group_id'];
        DocumentSnapshot? oldGroupSnapshot;
        DocumentReference? oldGroupRef;

        // 3. Se houver um grupo antigo, pega o estado dele
        if (oldGroupId != null) {
          oldGroupRef = _firestore.collection('groups').doc(oldGroupId);
          oldGroupSnapshot = await transaction.get(oldGroupRef);
        }

        // --- ESCRITAS DEPOIS ---

        // Se o usuário já estiver no grupo alvo, não faz nada.
        if (oldGroupId == _groupId) {
          return;
        }

        // 4. Se o usuário estava em um grupo antigo e ele existe, decrementa o contador
        if (oldGroupId != null &&
            oldGroupSnapshot != null &&
            oldGroupSnapshot.exists) {
          transaction.update(oldGroupRef!, {
            'member_count': FieldValue.increment(-1),
          });
        }

        // 5. Atualiza o group_id do usuário para o novo grupo
        transaction.update(userRef, {'group_id': _groupId});

        // 6. Incrementa o contador de membros do novo grupo
        transaction.update(newGroupRef, {
          'member_count': FieldValue.increment(1),
        });
      });

      if (mounted) {
        // Mostra o popup de boas-vindas
        _showWelcomeDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao entrar no grupo: ${e.toString()}')),
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

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pode buscar a foto do admin dinamicamente
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.amber,
                child: Icon(Icons.star, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                "Boas-vindas!",
                style: AppTextStyles.lightTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                "Você entrou no grupo '${_groupData?['name'] ?? ''}'. Agora você receberá todas as notificações e atualizações da sua linha.",
                textAlign: TextAlign.center,
                style: AppTextStyles.lightBody.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Fecha o popup e a tela de vinculação, voltando para a tela de notificações já atualizada
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final Color textPrimaryColor =
        isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Vincular a um Grupo',
          style: AppTextStyles.lightTitle.copyWith(color: textPrimaryColor),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: _groupData == null ? _buildSearchUI() : _buildGroupDetailsUI(),
      ),
    );
  }

  Widget _buildSearchUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insira o código da sua linha',
          style: AppTextStyles.lightTitle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          'Peça ao gestor do seu transporte o código de convite para encontrar seu grupo.',
          style: AppTextStyles.lightBody,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _codeController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: 'Código do Grupo',
            suffixIcon:
                _isLoading
                    ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _findGroup,
                    ),
          ),
        ),
        if (_errorMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }

  Widget _buildGroupDetailsUI() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFFC5FC61), // Usando uma cor da sua paleta
          child: Icon(Icons.directions_bus, size: 50, color: Colors.black),
        ),
        const SizedBox(height: 16),
        Text(
          _groupData?['name'] ?? 'Nome do Grupo',
          style: AppTextStyles.lightTitle.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          _groupData?['description'] ?? 'Descrição do grupo não disponível.',
          textAlign: TextAlign.center,
          style: AppTextStyles.lightBody.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 24),
        if (_groupMembers.isNotEmpty) _buildMemberAvatars(),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightPrimary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _isLoading ? null : _joinGroup,
          child:
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                    'Entrar no Grupo',
                    style: TextStyle(fontSize: 16),
                  ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            setState(() {
              _groupData = null;
              _codeController.clear();
            });
          },
          child: const Text('Procurar outro grupo'),
        ),
      ],
    );
  }

  Widget _buildMemberAvatars() {
    return Column(
      children: [
        Text(
          'Membros da Linha',
          style: AppTextStyles.lightBody.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: -12, // Faz os avatares se sobreporem um pouco
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children:
              _groupMembers.map((member) {
                return CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      // Corrigido para usar o campo e ID corretos
                      member['photoURL'] ??
                          'https://i.pravatar.cc/150?u=${member['id']}',
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
