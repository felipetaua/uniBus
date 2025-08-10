import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/features/estudante/loja/product_detail_page.dart';
import 'package:bus_attendance_app/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PromotionalBanner {
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Color> gradientColors;

  PromotionalBanner({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.gradientColors,
  });
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  int _selectedCategoryIndex = 0;
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  Map<String, dynamic>? _userData;

  final List<PromotionalBanner> banners = [
    PromotionalBanner(
      title: 'Ganhe 30% OFF',
      subtitle: 'Em avatares lendários. Oferta por tempo limitado!',
      imageUrl:
          'https://cdn3d.iconscout.com/3d/premium/thumb/gamer-avatar-6743411-5558485.png',
      gradientColors: [const Color(0xFF4A90E2), const Color(0xFF50E3C2)],
    ),
    PromotionalBanner(
      title: 'Novos Fundos!',
      subtitle: 'Explore cenários incríveis para seu perfil.',
      imageUrl:
          'https://i.pinimg.com/564x/e7/3a/1d/e73a1d1bf1c41be958a157d763f592a0.jpg',
      gradientColors: [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
    ),
    PromotionalBanner(
      title: 'Ícones Exclusivos',
      subtitle: 'Mostre seu estilo com ícones únicos.',
      imageUrl:
          'https://cdn3d.iconscout.com/3d/premium/thumb/trophy-5498873-4592741.png',
      gradientColors: [const Color(0xFFF857A6), const Color(0xFFFF5858)],
    ),
  ];

  final List<String> categories = [
    'Todos',
    'Avatares',
    'Planos de Fundo',
    'Emotes',
    'Cosméticos',
    'Ícones',
  ];

  final List<Product> featuredProducts = [
    const Product(
      id: 'prod_001',
      name: 'Avatar Mago Cósmico',
      imageUrl:
          'https://img.freepik.com/fotos-premium/um-personagem-de-desenho-animado-com-cabelo-azul-e-uma-jaqueta-roxa_902639-67626.jpg',
      price: 135,
      stock: '15 restantes',
      rating: 4.8,
      reviewCount: 201,
      description:
          'Um avatar místico que canaliza o poder das estrelas. Perfeito para quem busca um visual mágico e imponente.',
      category: 'Avatares',
    ),
    const Product(
      id: 'prod_002',
      name: 'Fundo Galáxia Animada',
      imageUrl:
          'https://i.pinimg.com/736x/3a/05/3e/3a053e1f6a3b216892b1574d5389a084.jpg',
      price: 95,
      stock: '32 restantes',
      rating: 4.9,
      reviewCount: 543,
      description:
          'Leve seu perfil para outra dimensão com este fundo de galáxia animado. As estrelas se movem suavemente, criando um efeito hipnotizante.',
      category: 'Planos de Fundo',
    ),
    const Product(
      id: 'prod_003',
      name: 'Avatar Neon Punk',
      imageUrl: 'https://unavatar.io/github/casey',
      price: 110,
      stock: '8 restantes',
      rating: 4.7,
      reviewCount: 150,
      description:
          'Direto de um futuro cyberpunk, este avatar combina luzes neon com uma atitude rebelde. Estoque limitado!',
      category: 'Avatares',
    ),
  ];

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
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

    return Stack(
      children: [
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
                colors: [backgroundColor.withOpacity(0.0), backgroundColor],
                stops: const [0.2, 1.0],
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Cabeçalho com boas-vindas e perfil --
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?u=a042581f4e29026704d',
                          ), // Imagem de avatar aleatória
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Suas Unicoins',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icons/coin_icon.png',
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _userData != null
                                      ? (_userData!['coins'] ?? 0).toString()
                                      : '...',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.card_giftcard_outlined,
                          size: 24,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // -- Barra de Pesquisa --
                TextField(
                  decoration: InputDecoration(
                    hintText: 'O que você procura?',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.filter_list),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
                const SizedBox(height: 20),

                // -- Filtros de Categoria --
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return CategoryButton(
                        text: categories[index],
                        isSelected: _selectedCategoryIndex == index,
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // -- Banner Promocional --
                Column(
                  children: [
                    SizedBox(
                      height: 160,
                      child: PageView.builder(
                        controller: _bannerController,
                        itemCount: banners.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentBannerIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final banner = banners[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: banner.gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        banner.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        banner.subtitle,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor:
                                              banner.gradientColors.first,
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18.0,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 16,
                                          ),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('Comprar Agora'),
                                      ),
                                    ],
                                  ),
                                ),
                                Image.network(
                                  banner.imageUrl,
                                  width: 100,
                                  height: 100,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.error,
                                            color: Colors.white,
                                          ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(banners.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 8,
                          width: _currentBannerIndex == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color:
                                _currentBannerIndex == index
                                    ? Colors.blueAccent
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // -- Seção de Produtos em Destaque --
                const Text(
                  'Itens em Destaque',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredProducts.length,
                    itemBuilder: (context, index) {
                      final product = featuredProducts[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: ProductCard(product: product),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Widget para os botões de categoria
class CategoryButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryButton({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.black,
          backgroundColor: isSelected ? Colors.blueAccent : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: isSelected ? 2 : 0,
        ),
        child: Text(text),
      ),
    );
  }
}

// Widget para o cartão de produto
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Hero(
                    tag: 'product-image-${product.id}',
                    child: _buildProductImage(product),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {},
                      iconSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/coin_icon.png',
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.price.toString(),
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.stock,
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating} (${product.reviewCount})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
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
    );
  }
}

/// Constrói o widget de imagem do produto, decidindo entre carregar
/// da rede (http) ou de um asset local.
Widget _buildProductImage(Product product) {
  final bool isNetworkImage =
      product.imageUrl.startsWith('http://') ||
      product.imageUrl.startsWith('https://');

  final Widget errorWidget = Container(
    height: 150,
    color: Colors.grey[200],
    child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
  );

  if (isNetworkImage) {
    return Image.network(
      product.imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => errorWidget,
    );
  } else {
    return Image.asset(
      product.imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => errorWidget,
    );
  }
}
