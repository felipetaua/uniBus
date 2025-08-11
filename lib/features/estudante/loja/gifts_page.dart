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
      }
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
              _userData != null ? (_userData!['coins'] ?? 0).toString() : '...',
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
                  'Comprar',
                  () => _showBuyCoinsModal(context),
                ),
                _buildActionItem(Icons.redeem, 'Receber', () {
                  // TODO: Implementar lógica para receber recompensas
                }),
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
}

void _showBuyCoinsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled:
        true, // Permite que o modal ocupe mais da metade da tela
    backgroundColor:
        Colors
            .transparent, // Torna o fundo do modal transparente para a imagem vazar
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
          mainAxisSize: MainAxisSize.min, // Faz a coluna se ajustar ao conteúdo
          children: [
            // Imagem do cabeçalho
            Image.asset('assets/header_coins.png'),

            // Conteúdo principal do modal
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'Entrar na minha conta',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Compre ou ganhe Unicoins e utilize como troca para itens exclusivos, e adiciona vantagens.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // Itens da lista de pacotes
                  _buildUnicoinPackageItem(
                    imagePath: 'assets/pacote_medio.png',
                    title: 'Pacote Médio de Unicoins',
                    subtitle: '250 Unicoins',
                    price: 'R\$ 0,00',
                  ),
                  const SizedBox(height: 16),
                  _buildUnicoinPackageItem(
                    imagePath: 'assets/pacote_grande.png',
                    title: 'Pacote Grande de Unicoins',
                    subtitle: '600 Unicoins',
                    price: 'R\$ 0,00',
                  ),
                ],
              ),
            ),

            // Banner "GRÁTIS" na parte inferior
            // TODO: Substitua 'assets/gratis_banner.png' pelo caminho da sua imagem
            Image.asset(
              'assets/gratis_banner.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ],
        ),
      );
    },
  );
}

// Widget reutilizável para criar cada item da lista de pacotes
Widget _buildUnicoinPackageItem({
  required String imagePath,
  required String title,
  required String subtitle,
  required String price,
}) {
  return Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8A2BE2), // Cor roxa
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
