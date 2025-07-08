import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrHubScreen extends StatefulWidget {
  final String studentId;
  final int initialIndex;

  const QrHubScreen({
    super.key,
    required this.studentId,
    this.initialIndex = 0,
  });

  @override
  State<QrHubScreen> createState() => _QrHubScreenState();
}

class _QrHubScreenState extends State<QrHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessingScan = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Escanear'),
            Tab(icon: Icon(Icons.qr_code_2), text: 'Meu Código'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba de Scanner
          _buildScannerView(),
          // Aba de Exibição do QR Code
          _buildDisplayView(),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) async {
            if (_isProcessingScan) return;

            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
              setState(() {
                _isProcessingScan = true;
              });
              await _scannerController.stop();
              final String code = barcodes.first.rawValue!;
              if (mounted) {
                Navigator.of(context).pop(code);
              }
            }
          },
        ),
        // Overlay para guiar o usuário
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 4),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayView() {
    return Container(
      color: Colors.blue.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: widget.studentId,
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Apresente este código ao organizador do ônibus para confirmar sua presença.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
