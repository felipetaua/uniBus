import 'package:bus_attendance_app/core/theme/colors.dart';
import 'package:bus_attendance_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; 

class Driver {
  final String name;
  final String avatarUrl;

  Driver({required this.name, required this.avatarUrl});
}

// Modelo de dados para o ônibus
class Bus {
  final String model;
  final String plate;

  Bus({required this.model, required this.plate});
}

class PickupPoint {
  final String name;
  final String address; //  Por coordenadas no futuro

  PickupPoint({required this.name, required this.address});
}

// Modelo de dados para a rota
class BusRoute {
  final String name;
  final Driver driver; // Atualizado de String para Driver
  final Bus bus; // Adicionado
  final List<PickupPoint> points;
  final String qrCodeData; // Adicionado para o QR Code

  BusRoute({
    required this.name,
    required this.driver,
    required this.bus,
    required this.points,
    required this.qrCodeData,
  });
}

class RotesPages extends StatefulWidget {
  const RotesPages({super.key});

  @override
  State<RotesPages> createState() => _RotesPagesState();
}

class _RotesPagesState extends State<RotesPages> {
  // TODO: Substituir estes dados mockados por uma chamada ao Firebase
  final List<BusRoute> _routes = [
    BusRoute(
      name: 'Rota Centro - Univel',
      driver: Driver(
        name: 'Carlos Souza',
        avatarUrl: 'https://i.pravatar.cc/150?u=driver1',
      ),
      bus: Bus(model: 'Marcopolo G7', plate: 'ABC-1234'),
      qrCodeData: 'UNIBUS_ROUTE_ID_001',
      points: [
        PickupPoint(name: 'Ponto A', address: 'Praça Central'),
        PickupPoint(name: 'Ponto B', address: 'Av. Brasil, 123'),
        PickupPoint(name: 'Ponto C', address: 'Terminal Urbano'),
      ],
    ),
    BusRoute(
      name: 'Rota Bairro Norte - FAG',
      driver: Driver(
        name: 'Mariana Lima',
        avatarUrl: 'https://i.pravatar.cc/150?u=driver2',
      ),
      bus: Bus(model: 'Irizar i6', plate: 'XYZ-5678'),
      qrCodeData: 'UNIBUS_ROUTE_ID_002',
      points: [
        PickupPoint(name: 'Ponto X', address: 'Rua das Flores, 45'),
        PickupPoint(name: 'Ponto Y', address: 'Supermercado Norte'),
      ],
    ),
  ];

  // Função para exibir o diálogo de alerta de emergência
  void _showEmergencyAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Alerta de Emergência'),
          content: const Text(
            'Deseja notificar todos os estudantes sobre um problema com o ônibus (ex: quebrou)? Esta ação não pode ser desfeita.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Confirmar e Enviar Alerta',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                // TODO: Implementar a lógica de envio de notificação via FCM
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alerta de emergência enviado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Função para exibir o QR Code da rota
  void _showQrCodeDialog(BusRoute route) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QR Code para a Rota',
                  style: AppTextStyles.lightTitle.copyWith(fontSize: 18),
                ),
                Text(route.name, style: AppTextStyles.lightBody),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: route.qrCodeData,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Estudantes devem escanear este código para confirmar a presença no ônibus.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  // Função para exibir o menu de adição
  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.add_road_outlined),
                title: const Text('Criar Nova Rota'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navegar para a tela de criação de rota
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_bus_outlined),
                title: const Text('Cadastrar Ônibus'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navegar para a tela de cadastro de ônibus
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: const Text('Cadastrar Motorista'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navegar para a tela de cadastro de motorista
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final Color backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final Color surfaceColor =
        isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
    final Color textPrimaryColor =
        isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color textSecondaryColor =
        isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final Color primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color onPrimaryColor =
        isDarkMode ? AppColors.darkOnPrimary : AppColors.lightOnPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Fundo com gradiente
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
          // Conteúdo principal rolável
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(onPrimaryColor),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Suas Rotas Ativas',
                      style: AppTextStyles.lightTitle.copyWith(
                        fontSize: 20,
                        color: textPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _routes.length,
                    itemBuilder: (context, index) {
                      final route = _routes[index];
                      return _buildRouteCard(
                        route,
                        surfaceColor,
                        textPrimaryColor,
                        textSecondaryColor,
                        primaryColor,
                      );
                    },
                  ),
                  const SizedBox(height: 80), // Espaço para o FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Adicionar',
      ),
    );
  }

  Widget _buildHeader(Color onPrimaryColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Gerenciar Rotas',
            style: AppTextStyles.lightTitle.copyWith(
              color: onPrimaryColor,
              fontSize: 24,
            ),
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
            ),
            child: IconButton(
              icon: Icon(Icons.warning_amber_rounded, color: onPrimaryColor),
              tooltip: 'Enviar Alerta de Emergência',
              onPressed: _showEmergencyAlert,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
    BusRoute route,
    Color surfaceColor,
    Color textPrimaryColor,
    Color textSecondaryColor,
    Color primaryColor,
  ) {
    return Card(
      elevation: 4,
      color: surfaceColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              route.name,
              style: AppTextStyles.lightTitle.copyWith(
                fontSize: 18,
                color: textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.person_outline,
              'Motorista: ${route.driver.name}',
              textSecondaryColor,
            ),
            _buildInfoRow(
              Icons.directions_bus_outlined,
              'Ônibus: ${route.bus.plate}',
              textSecondaryColor,
            ),
            _buildInfoRow(
              Icons.location_on_outlined,
              '${route.points.length} pontos de parada',
              textSecondaryColor,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.pin_drop_outlined,
                      label: 'Ao Vivo',
                      onTap: () {
                        // TODO: Navegar para a tela de localização em tempo real
                      },
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'QR Code',
                      onTap: () => _showQrCodeDialog(route),
                    ),
                  ],
                ),
                TextButton.icon(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: primaryColor,
                  ),
                  label: Text('Editar', style: TextStyle(color: primaryColor)),
                  onPressed: () {
                    // TODO: Navegar para a tela de edição da rota
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.lightBody.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkPrimary
            : AppColors.lightPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: primaryColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
