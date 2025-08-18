import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bus_attendance_app/core/theme/colors.dart';

class GiftsScreen extends StatefulWidget {
  const GiftsScreen({super.key});

  @override
  State<GiftsScreen> createState() => _GiftsScreenState();
}

class _GiftsScreenState extends State<GiftsScreen> {
  Map<String, dynamic>? _userData;
  bool _canClaimDailyReward = false;
  bool _isClaimingReward = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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
          _userData = userDoc.data();
        });
        _checkDailyRewardStatus();
      }
    }
  }

  void _checkDailyRewardStatus() {
    if (_userData == null) {
      if (mounted) setState(() => _canClaimDailyReward = false);
      return;
    }

    if (_userData!.containsKey('lastDailyRewardClaim')) {
      final Timestamp lastClaimTimestamp = _userData!['lastDailyRewardClaim'];
      final DateTime lastClaimDate = lastClaimTimestamp.toDate();
      final DateTime now = DateTime.now();

      // Compara apenas a data (ignora a hora)
      if (lastClaimDate.year == now.year &&
          lastClaimDate.month == now.month &&
          lastClaimDate.day == now.day) {
        if (mounted) setState(() => _canClaimDailyReward = false); // Já coletou
      } else {
        if (mounted)
          setState(() => _canClaimDailyReward = true); // Pode coletar
      }
    } else {
      // Nunca coletou antes
      if (mounted) setState(() => _canClaimDailyReward = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo em gradiente (igual ao da tela da loja)
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
                  colors: [
                    AppColors.lightBackground.withOpacity(0.0),
                    AppColors.lightBackground,
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),
          // Conteúdo da página
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho personalizado
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.2),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Recompensas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildPointsCard(),
                  const SizedBox(height: 16),
                  _buildLevelCard(),
                  const SizedBox(height: 16),
                  _buildReferralCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card que mostra os pontos do usuário
  Widget _buildPointsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/coin_icon.png',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Minhas Unicoins',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _userData != null
                  ? ((_userData!['coins'] ?? 0) as num).toInt().toString()
                  : '...',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(
                  Icons.monetization_on_outlined,
                  'Comprar', // Alterado para chamar o método da classe
                  _showBuyCoinsModal,
                ),
                _buildActionItem(
                  Icons.redeem,
                  'Receber',
                  _showReceiveCoinsModal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card que mostra o nível e progresso
  Widget _buildLevelCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.workspace_premium_outlined, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Gold (Level 3)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Faltam 1090 Unicoins para o nível Ouro',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: 0.7, // 70% de progresso
                minHeight: 10,
                backgroundColor: Color(0xFFEEEEEE),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card para o sistema de "Indique um amigo"
  Widget _buildReferralCard(BuildContext context) {
    const referralLink = 'https://www.unibus.com/bfgG3';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Refer Your Friends',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text('🔸 Você ganha 200 Unicoins'),
            const SizedBox(height: 4),
            const Text('🔸 Eles ganham um cupom de item grátis'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      referralLink,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(text: referralLink),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copiado!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Copy'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('You have referred 0 friends'),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.facebook, color: Colors.blue),
                ),
                // Para o ícone do Twitter/X, pode ser necessário um pacote como font_awesome_flutter
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.public, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para os itens de "Earn" e "Redeem"
  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.amber, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Função para adicionar moedas ao usuário no Firestore
  Future<void> _addCoins(int amount) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Fecha o modal
    Navigator.pop(context);

    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid);

      // Usa FieldValue.increment para uma atualização atômica e segura
      await userDocRef.update({'coins': FieldValue.increment(amount)});

      // Recarrega os dados do usuário para atualizar a UI
      _loadUserData();

      // Mostra uma mensagem de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$amount Unicoins adicionadas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Mostra uma mensagem de erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar moedas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _claimDailyReward() async {
    // Fecha o modal antes de processar
    Navigator.pop(context);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid);
    const int rewardAmount = 10;

    try {
      // Usar uma transação para garantir a consistência dos dados
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        final data = snapshot.data();

        if (data == null) {
          throw Exception("Usuário não encontrado.");
        }

        // Verifica se a recompensa já foi coletada hoje
        if (data.containsKey('lastDailyRewardClaim')) {
          final Timestamp lastClaimTimestamp = data['lastDailyRewardClaim'];
          final DateTime lastClaimDate = lastClaimTimestamp.toDate();
          final DateTime now = DateTime.now();

          // Compara apenas a data (ignora a hora)
          if (lastClaimDate.year == now.year &&
              lastClaimDate.month == now.month &&
              lastClaimDate.day == now.day) {
            // Lança uma exceção se já foi coletado hoje
            throw Exception("Recompensa diária já coletada. Volte amanhã!");
          }
        }

        // Se não foi coletada, atualiza as moedas e a data do último resgate
        transaction.update(userDocRef, {
          'coins': FieldValue.increment(rewardAmount),
          'lastDailyRewardClaim':
              Timestamp.now(), // Atualiza para o momento atual
        });
      });

      // Se a transação for bem-sucedida
      _loadUserData(); // Atualiza a UI e o status do botão
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+$rewardAmount Unicoins coletadas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Se ocorrer um erro ou se a recompensa já foi coletada
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isClaimingReward = false);
    }
  }

  void _showBuyCoinsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (builderContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/header_coins.png'),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Entrar na minha conta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Compre ou ganhe Unicoins e utilize como troca para itens exclusivos, e adiciona vantagens.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    _buildUnicoinPackageItem(
                      imagePath: 'assets/images/pacote_medio.png',
                      title: 'Pacote Médio de Unicoins',
                      subtitle: '250 Unicoins',
                      price: 'R\$ 0,00',
                      amount: 250,
                    ),
                    const SizedBox(height: 16),
                    _buildUnicoinPackageItem(
                      imagePath: 'assets/images/pacote_grande.png',
                      title: 'Pacote Grande de Unicoins',
                      subtitle: '600 Unicoins',
                      price: 'R\$ 0,00',
                      amount: 600,
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/gratis_banner.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnicoinPackageItem({
    required String imagePath,
    required String title,
    required String subtitle,
    required String price,
    required int amount,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => _addCoins(amount),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8A2BE2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Modal para ganhar moedas
  void _showReceiveCoinsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (builderContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/header_coins.png'),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Ganhe Unicoins Grátis',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete tarefas e desafios para acumular Unicoins e trocar por itens incríveis na loja.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    _buildEarnCoinOptionItem(
                      icon: Icons.login,
                      title: 'Login Diário',
                      subtitle:
                          _canClaimDailyReward
                              ? 'Ganhe moedas por entrar todo dia'
                              : 'Recompensa já coletada hoje',
                      reward: '+10',
                      onTap: _claimDailyReward,
                      isEnabled: _canClaimDailyReward,
                      isLoading: _isClaimingReward,
                    ),
                    const SizedBox(height: 16),
                    _buildEarnCoinOptionItem(
                      icon: Icons.slow_motion_video,
                      title: 'Assistir Anúncio',
                      subtitle: 'Ganhe moedas assistindo um vídeo',
                      reward: '+5',
                      onTap: () {
                        // TODO: Implementar lógica para assistir anúncios
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Recompensa por anúncio ainda não implementada.',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/gratis_banner.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEarnCoinOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String reward,
    required VoidCallback onTap,
    bool isEnabled = true,
    bool isLoading = false,
  }) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, size: 30, color: Colors.grey[700]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: isEnabled && !isLoading ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isEnabled ? const Color(0xFF42A5F5) : Colors.grey.shade400,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon:
              isLoading
                  ? Container() // Não mostra ícone durante o loading
                  : Image.asset(
                    'assets/icons/coin_icon.png',
                    height: 16,
                    width: 16,
                  ),
          label:
              isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Text(
                    reward,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ],
    );
  }
}
