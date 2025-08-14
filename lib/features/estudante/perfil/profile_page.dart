import 'package:bus_attendance_app/data/auth_services.dart';
import 'package:bus_attendance_app/features/auth/login_student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  User? _user;
  Map<String, dynamic>? _userData;
  late TabController _tabController;
  late TabController _collectionTabController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _tabController = TabController(length: 2, vsync: this);
    _collectionTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _collectionTabController.dispose();
    super.dispose();
  }

  // Carrega os dados do usuário logado
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
          _user = currentUser;
          _userData = userDoc.data();
        });
      }
    }
  }

  // Equipa um item selecionado pelo usuário
  Future<void> _equipItem(
    String itemId,
    String category,
    String imageUrl,
  ) async {
    if (_user == null) return;

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid);
    String fieldToUpdate;
    String idFieldToUpdate;

    if (category == 'Planos de Fundo') {
      fieldToUpdate = 'equipped_background_image_url';
      idFieldToUpdate = 'equipped_background_id';
    } else if (category == 'Avatares') {
      fieldToUpdate = 'equipped_avatar_image_url';
      idFieldToUpdate = 'equipped_avatar_id';
    } else {
      return;
    }

    await userRef.update({fieldToUpdate: imageUrl, idFieldToUpdate: itemId});
    _loadUserData(); // Recarrega os dados para atualizar a UI
  }

  @override
  Widget build(BuildContext context) {
    final String? backgroundUrl = _userData?['equipped_background_image_url'];
    final String? avatarUrl = _userData?['equipped_avatar_image_url'];

    // Logica para determinar o provedor de imagem para o plano de fundo
    ImageProvider backgroundProvider;
    if (backgroundUrl != null && backgroundUrl.isNotEmpty) {
      if (backgroundUrl.startsWith('http')) {
        backgroundProvider = NetworkImage(backgroundUrl);
      } else {
        backgroundProvider = AssetImage(backgroundUrl);
      }
    } else {
      backgroundProvider = const AssetImage('assets/items/bg/bg-10.png');
    }

    // Logica para determinar o widget de imagem para o avatar
    Widget? avatarWidget;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('http')) {
        avatarWidget = Image.network(
          avatarUrl,
          height: 120,
          fit: BoxFit.contain,
        );
      } else {
        avatarWidget = Image.asset(avatarUrl, height: 120, fit: BoxFit.contain);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[200],
                        image: DecorationImage(
                          image: backgroundProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child:
                          avatarWidget != null
                              ? Center(child: avatarWidget)
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _user?.displayName ?? 'User Guest',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            // Exibe os 6 primeiros caracteres do UID do usuário
                            'ID: ${_user != null && _user!.uid.length >= 6 ? _user!.uid.substring(0, 6).toUpperCase() : '...'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              if (_user?.uid != null) {
                                Clipboard.setData(
                                  ClipboardData(text: _user!.uid),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'ID copiado para a área de transferência!',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Icon(
                              Icons.copy,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Level',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const SizedBox(
                                height: 10,
                                child: LinearProgressIndicator(
                                  value:
                                      0.7, // Exemplo de progresso da barra em %
                                  backgroundColor: Color(0xFFE0E0E0),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(
                                      0xFFB06DF9,
                                    ), // Adicionar a funcionalidade de trocar a cor da barra de progresso entre essas cores: Color(0xFFB06DF9), Color(0xFF828EF3), Color(0xFF84CFB2), Color(0xFFCAFF5C),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            children: [
                              Image.asset(
                                'assets/icons/stack-coins.png',
                                width: 30,
                                height: 30,
                              ),
                              const Text(
                                'x2',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: [
                    Image.asset(
                      'assets/icons/tropy_icon.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '-',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Melhor Rank',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/icons/coin_icon.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userData != null
                          ? (_userData!['coins'] ?? 0).toString()
                          : '...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Unicoins', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/icons/xp_icon.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userData != null
                          ? (_userData!['xp'] ?? 0).toString()
                          : '...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Experiência',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.purple,
                  indicatorWeight: 4.0,
                  tabs: const [
                    Tab(text: 'Configurações'),
                    Tab(text: 'Coleção'),
                  ],
                ),
                Expanded(
                  // Adicionado Expanded para que o TabBarView ocupe o espaço restante
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Aba de Configurações
                      ListView(
                        shrinkWrap: true,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('Sair'),
                            onTap: () async {
                              await AuthService().signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder:
                                      (context) => const LoginStudentPage(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                      // Aba de Coleção
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            _user != null
                                ? FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_user!.uid)
                                    .collection('inventory')
                                    .snapshots()
                                : null,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text('Você ainda não possui itens.'),
                            );
                          }

                          final inventoryDocs = snapshot.data!.docs;
                          final List<DocumentSnapshot> backgrounds =
                              inventoryDocs
                                  .where(
                                    (doc) =>
                                        doc['category'] == 'Planos de Fundo',
                                  )
                                  .toList();
                          final List<DocumentSnapshot> avatars =
                              inventoryDocs
                                  .where((doc) => doc['category'] == 'Avatares')
                                  .toList();

                          final String? equippedBgId =
                              _userData?['equipped_background_id'];
                          final String? equippedAvatarId =
                              _userData?['equipped_avatar_id'];

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple[700]!,
                                        Colors.blue[400]!,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/gift-shop.png',
                                        width: 80,
                                        height: 80,
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sua Coleção',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Equipe seus itens favoritos para personalizar seu perfil.',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              TabBar(
                                controller: _collectionTabController,
                                labelColor: Colors.black,
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: Colors.purple,
                                tabs: [
                                  Tab(text: 'Planos de Fundo'),
                                  Tab(text: 'Avatares'),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  controller: _collectionTabController,
                                  children: [
                                    _buildItemGrid(
                                      backgrounds, // Corrigido
                                      equippedBgId,
                                    ),
                                    _buildItemGrid(
                                      avatars, // Corrigido
                                      equippedAvatarId,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid(List<DocumentSnapshot> items, String? equippedItemId) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum item nesta categoria.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2 / 3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final itemData = item.data() as Map<String, dynamic>;
        final bool isSelected = item.id == equippedItemId;

        return CollectionItemCard(
          imageUrl: itemData['imageUrl'],
          isSelected: isSelected,
          onTap:
              () => _equipItem(
                item.id,
                itemData['category'],
                itemData['imageUrl'],
              ),
        );
      },
    );
  }
}

class CollectionItemCard extends StatelessWidget {
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const CollectionItemCard({
    super.key,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Lógica para decidir qual widget de imagem usar (Asset ou Network)
    Widget imageWidget;
    if (imageUrl.startsWith('http')) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
    } else {
      imageWidget = Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border:
              isSelected
                  ? Border.all(color: Colors.purple, width: 3)
                  : Border.all(color: Colors.transparent, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageWidget,
        ),
      ),
    );
  }
}
