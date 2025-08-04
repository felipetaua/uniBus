import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Modelo de dados para cada rota
class RouteInfo {
  final String id;
  final String name;
  final String boardingPoint;
  final String disembarkPoint;

  RouteInfo({
    required this.id,
    required this.name,
    required this.boardingPoint,
    required this.disembarkPoint,
  });
}

// A tela principal de Rotas
class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  // Dados de exemplo para as rotas
  final List<RouteInfo> routes = [
    RouteInfo(
      id: 'RT-001',
      name: 'Rota 1',
      boardingPoint: 'Terminal Central',
      disembarkPoint: 'Campus II',
    ),
    RouteInfo(
      id: 'RT-002',
      name: 'Rota 2',
      boardingPoint: 'Bairro Novo',
      disembarkPoint: 'Reitoria',
    ),
    RouteInfo(
      id: 'RT-003',
      name: 'Rota 3',
      boardingPoint: 'Shopping Plaza',
      disembarkPoint: 'Biblioteca Central',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF1A1A1A,
      ), // Cor de fundo escura do cabeçalho
      body: Stack(children: [_buildHeader(), _buildMainContent()]),
    );
  }

  // Constrói o cabeçalho com o logo
  Widget _buildHeader() {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFF141414),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: double.infinity,
            color: const Color(0xFF141414),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.0,
              bottom: 16.0,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo-texto-image.png',
                height: 40,
              ),
            ),
          ),
          const Spacer(), 
        ],
      ),
    );
  }

  // Constrói a área de conteúdo principal
  Widget _buildMainContent() {
    return Container(
      margin: const EdgeInsets.only(top: 180),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  return _buildRouteCard(routes[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.sync_alt, color: Colors.black),
          label: const Text(
            'Adicionar rota',
            style: TextStyle(color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.grey),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 2,
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            side: const BorderSide(color: Colors.grey),
          ),
          child: const Icon(Icons.filter_list, color: Colors.black),
        ),
      ],
    );
  }

  // Constrói o card de uma rota
  Widget _buildRouteCard(RouteInfo route) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.green.shade100.withOpacity(0.7),
              Colors.lightGreen.shade200.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                // QR Code
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: route.id, // O dado a ser codificado no QR Code
                    version: QrVersions.auto,
                    size: 80.0,
                  ),
                ),
                const SizedBox(width: 16),
                // Informações da Rota
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ponto de embarque: ${route.boardingPoint}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ponto de desembarque: ${route.disembarkPoint}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.visibility,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {},
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
