import 'package:flutter/material.dart';

class RouteMapScreen extends StatelessWidget {
  const RouteMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota do Ônibus'),
      ),
      body: Column(
        children: [
          // Placeholder para o mapa
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[300],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Mapa em tempo real em breve!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lista de pontos de parada
          Expanded(
            flex: 2,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'Pontos de Parada',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildStopTile(context, 'Ponto 1: Praça Central', '17:00'),
                _buildStopTile(context, 'Ponto 2: Av. Principal, 123', '17:10'),
                _buildStopTile(context, 'Ponto 3: Supermercado', '17:15'),
                _buildStopTile(
                    context, 'Ponto 4: Ponto Final (Universidade)', '17:30'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopTile(BuildContext context, String title, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.blue),
        title: Text(title),
        trailing: Text(time, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
