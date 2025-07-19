import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'avatar_customization_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw 'Usuário não encontrado.';
      }

      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('points, avatar_config')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _profileData = {
            'name': user.userMetadata?['name'] ?? 'Sem nome',
            'email': user.email ?? 'Sem e-mail',
            'matricula': user.userMetadata?['matricula'] ?? 'Não informada',
            'points': profileResponse?['points'] ?? 0,
            'avatar_config': profileResponse?['avatar_config'],
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar perfil: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sair: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _profileData == null
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Não foi possível carregar o perfil.'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ))
                : RefreshIndicator(
                    onRefresh: _loadProfile,
                    child: CustomScrollView(
                      slivers: [
                        _buildSliverAppBar(),
                        _buildUserInfo(),
                        _buildActions(),
                        _buildLogoutButton()
                      ],
                    )));
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.blue,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(_profileData!['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            )),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${_profileData!['email']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Pontos: ${_profileData!['points']}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return SliverList(
      delegate: SliverChildListDelegate([
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Customizar Avatar'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AvatarCustomizationScreen(),
            ));
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configurações'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tela de configurações em breve!')),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildLogoutButton() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _signOut,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
