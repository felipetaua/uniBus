import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Um modelo de dados simples para representar um produto
class Product {
  final String imageUrl;
  final String name;
  final double price;
  final int stock;
  final double rating;
  final int reviewCount;

  Product({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.stock,
    required this.rating,
    required this.reviewCount,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    // Use a nullable map to prevent a crash if the document data is unexpectedly null.
    final data = doc.data() as Map<String, dynamic>?;

    // If data is null, return a default 'error' product to avoid crashing the list.
    if (data == null) {
      return Product(
        imageUrl: '',
        name: 'Erro ao carregar',
        price: 0,
        stock: 0,
        rating: 0,
        reviewCount: 0,
      );
    }

    return Product(
      imageUrl: data['imageUrl'] ?? '',
      name: data['name'] ?? 'Produto sem nome',
      price: double.tryParse(data['price']?.toString() ?? '0.0') ?? 0.0,
      stock: int.tryParse(data['stock']?.toString() ?? '0') ?? 0,
      rating: double.tryParse(data['rating']?.toString() ?? '0.0') ?? 0.0,
      reviewCount: int.tryParse(data['reviewCount']?.toString() ?? '0') ?? 0,
    );
  }
}

class ProductListScreen extends StatelessWidget {
  ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Pesquisar Avatares',
            prefixIcon: const Icon(Icons.search, size: 20),
            fillColor: Colors.white,
            filled: true,
            isDense: true,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {}, // Ação do botão
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text('Raridade'), Icon(Icons.keyboard_arrow_down)],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Conteúdo principal com a grade de produtos
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 80,
            ), // Espaço para o botão flutuante
            child: Column(
              children: [
                // Barra de Filtros
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChipWidget(
                          label: 'Filtros',
                          icon: Icons.filter_list,
                        ),
                        FilterChipWidget(label: 'Avaliação'),
                        FilterChipWidget(label: 'Preço'),
                        FilterChipWidget(label: 'Cor'),
                      ],
                    ),
                  ),
                ),
                // Ícones de Categoria
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 16.0,
                  ),
                  child: SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CategoryIcon(
                          icon: Icons.apps,
                          label: 'Tudo',
                          isSelected: true,
                        ),
                        CategoryIcon(icon: Icons.landscape, label: 'Fundos'),
                        CategoryIcon(
                          icon: Icons.person_search,
                          label: 'Avatares',
                        ),
                        CategoryIcon(icon: Icons.shield, label: 'Ícones'),
                        CategoryIcon(icon: Icons.style, label: 'Kits'),
                      ],
                    ),
                  ),
                ),

                // Grade de produtos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('products')
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Algo deu errado: ${snapshot.error}'),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Nenhum produto encontrado.'),
                        );
                      }

                      final products =
                          snapshot.data!.docs
                              .map((doc) => Product.fromFirestore(doc))
                              .toList();

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 colunas
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.65,
                            ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return GridProductCard(product: product);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Botão Flutuante do Carrinho
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        children: [
                          TextSpan(text: 'Ver carrinho '),
                          TextSpan(
                            text: '3x',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icons/coin_icon.png',
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '385',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widgets de apoio (para manter o código principal limpo)

class FilterChipWidget extends StatelessWidget {
  final String label;
  final IconData? icon;
  const FilterChipWidget({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: icon != null ? Icon(icon, size: 18) : null,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (icon == null) const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
        onPressed: () {},
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  const CategoryIcon({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class GridProductCard extends StatelessWidget {
  final Product product;
  const GridProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: 150,
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
    );

    Widget imageWidget;
    if (product.imageUrl.isEmpty) {
      imageWidget = placeholder;
    } else if (product.imageUrl.startsWith('http')) {
      imageWidget = Image.network(
        product.imageUrl,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    } else {
      imageWidget = Image.asset(
        product.imageUrl,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                child: imageWidget,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icons/coin_icon.png',
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.price.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${product.stock} restantes',
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating} (${product.reviewCount})',
                      style: const TextStyle(fontSize: 11),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.add_circle,
                      color: Colors.blueAccent,
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
