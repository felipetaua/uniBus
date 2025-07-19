import 'package:bus_attendance_app/screens/avatar_customization_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late Future<Map<String, dynamic>> _dataFuture;
  late int _userPoints;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadStoreData();
  }

  Future<Map<String, dynamic>> _loadStoreData() async {
    final response = await Supabase.instance.client
        .from('store')
        .select('rewards(id, name, cost, image_url), inventory')
        .single()
        .execute();

    if (response.error != null) {
      throw response.error!;
    }

    final data = response.data as Map<String, dynamic>;
    _userPoints = data['inventory'] != null
        ? (data['inventory'] as List)
            .fold<int>(0, (sum, item) => sum + item['points'])
        : 0;

    return data;
  }

  Future<void> _purchaseItem(String rewardId, int cost) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Compra'),
        content:
            Text('Você tem certeza que quer gastar $cost pontos neste item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Supabase.instance.client.rpc(
        'purchase_reward',
        params: {'reward_id_to_purchase': rewardId},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Item comprado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Recarrega os dados para atualizar a UI
      setState(() {
        _dataFuture = _loadStoreData();
      });
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na compra: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocorreu um erro inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja de Recompensas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              avatar: const Icon(Icons.star, color: Colors.amber),
              label: Text('$_userPoints'),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _dataFuture = _loadStoreData();
          });
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }
            if (!snapshot.hasData ||
                (snapshot.data!['rewards'] as List).isEmpty) {
              return const Center(
                  child: Text('Nenhuma recompensa disponível.'));
            }

            final rewards =
                snapshot.data!['rewards'] as List<Map<String, dynamic>>;
            final inventory = snapshot.data!['inventory'] as Set<String>;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const AvatarCustomizationScreen(),
                        ));
                      },
                      icon: const Icon(Icons.face_retouching_natural),
                      label: const Text('Customizar meu Avatar'),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final reward = rewards[index];
                        final isOwned = inventory.contains(reward['id']);
                        final canAfford = _userPoints >= reward['cost'];

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.grey[200],
                                  child: reward['image_url'] != null
                                      ? Image.network(
                                          reward['image_url'],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(Icons.palette,
                                                      size: 48,
                                                      color: Colors.grey),
                                        )
                                      : const Icon(Icons.palette,
                                          size: 48, color: Colors.grey),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(reward['name'],
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton.icon(
                                  onPressed: isOwned || !canAfford
                                      ? null
                                      : () => _purchaseItem(
                                          reward['id'], reward['cost']),
                                  icon: isOwned
                                      ? const Icon(Icons.check)
                                      : const Icon(Icons.star, size: 16),
                                  label: Text(isOwned
                                      ? 'Adquirido'
                                      : '${reward['cost']}'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isOwned
                                        ? Colors.grey
                                        : Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        );
                      },
                      childCount: rewards.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
