import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:bus_attendance_app/features/groups/gerenciamento_grupo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Modelo de dados para o usuário/membro
class GroupMember {
  final String uid;
  final String name;
  final String avatarUrl;

  GroupMember({required this.uid, required this.name, required this.avatarUrl});

  factory GroupMember.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GroupMember(
      uid: doc.id,
      name: data['name'] ?? 'Nome não encontrado',
      avatarUrl: data['photoURL'] ?? '',
    );
  }
}

class GroupMembersPage extends StatefulWidget {
  final Group group;
  const GroupMembersPage({super.key, required this.group});

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRemoveMemberConfirmation(GroupMember member) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remover Membro'),
            content: Text(
              'Tem certeza que deseja remover ${member.name} do grupo?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  try {
                    // Usar um batch para garantir a atomicidade da operação
                    final batch = FirebaseFirestore.instance.batch();

                    // 1. Desvincula o usuário do grupo
                    final userRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(member.uid);
                    batch.update(userRef, {'group_id': null});

                    // 2. Decrementa a contagem de membros no grupo
                    final groupRef = FirebaseFirestore.instance
                        .collection('groups')
                        .doc(widget.group.id);
                    batch.update(groupRef, {
                      'member_count': FieldValue.increment(-1),
                    });

                    await batch.commit();

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${member.name} removido com sucesso.'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao remover membro: $e')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Remover',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
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
    final Color onPrimaryColor =
        isDarkMode ? AppColors.darkOnPrimary : AppColors.lightOnPrimary;

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
                    titlePadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    title: Text(
                      'Membros do Grupo',
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: textPrimaryColor),
                      decoration: InputDecoration(
                        hintText: 'Pesquisar membro...',
                        hintStyle: TextStyle(color: textSecondaryColor),
                        prefixIcon: Icon(
                          Icons.search,
                          color: textSecondaryColor,
                        ),
                        filled: true,
                        fillColor: surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('users')
                          .where('group_id', isEqualTo: widget.group.id)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text('Nenhum membro neste grupo ainda.'),
                        ),
                      );
                    }

                    var members =
                        snapshot.data!.docs
                            .map((doc) => GroupMember.fromFirestore(doc))
                            .where(
                              (member) => member.name.toLowerCase().contains(
                                _searchQuery,
                              ),
                            )
                            .toList();

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final member = members[index];
                        return _buildMemberTile(
                          member,
                          surfaceColor,
                          textPrimaryColor,
                          textSecondaryColor,
                        );
                      }, childCount: members.length),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(
    GroupMember member,
    Color surfaceColor,
    Color textPrimaryColor,
    Color textSecondaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Card(
        elevation: 2,
        color: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          leading: CircleAvatar(
            backgroundImage:
                member.avatarUrl.isNotEmpty
                    ? NetworkImage(member.avatarUrl)
                    : const AssetImage('assets/avatar/profile_placeholder.png')
                        as ImageProvider,
            radius: 30,
          ),
          title: Text(
            member.name,
            style: AppTextStyles.lightBody.copyWith(
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
              fontSize: 16,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.more_vert, color: textSecondaryColor),
            onPressed: () => _showRemoveMemberConfirmation(member),
          ),
        ),
      ),
    );
  }
}
