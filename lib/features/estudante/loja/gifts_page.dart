import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GiftsScreen extends StatelessWidget {
  const GiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
          child: Chip(
            label: const Text('? FAQ'),
            backgroundColor: Colors.white.withOpacity(0.3),
          ),
        ),
        title: const Text(
          'Welcome to\nPlus Rewards',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.history)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildPointsCard(),
              const SizedBox(height: 16),
              _buildLevelCard(),
              const SizedBox(height: 16),
              _buildReferralCard(context),
            ],
          ),
        ),
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
              children: const [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text('Points', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '2,000',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Equals \$250',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(Icons.card_giftcard, 'Earn'),
                _buildActionItem(Icons.redeem, 'Redeem'),
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
                Text('Gold (Level 3)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('1090 Points to Gold', style: TextStyle(color: Colors.grey)),
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
    const referralLink = 'https://www.gameball.co/bfgG3';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Refer Your Friends', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            const Text('🔸 You get \$20 Coupon'),
            const SizedBox(height: 4),
            const Text('🔸 They get Free Shipping Coupon'),
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
                      Clipboard.setData(const ClipboardData(text: referralLink));
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
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('You have referred 0 friends'),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.facebook, color: Colors.blue)),
                // Para o ícone do Twitter/X, pode ser necessário um pacote como font_awesome_flutter
                IconButton(onPressed: () {}, icon: const Icon(Icons.public, color: Colors.black)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para os itens de "Earn" e "Redeem"
  Widget _buildActionItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}