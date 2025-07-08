import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR Code'),
        actions: <Widget>[
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable:
                  controller.torchState, // Use controller.torchState
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  // Adiciona o caso para quando a lanterna não está disponível
                  case TorchState.unavailable:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.auto:
                    return const Icon(Icons.flash_auto, color: Colors.yellow);
                  default:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                }
              },
            ), // This is the missing parenthesis
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                return Icon(state == CameraFacing.front
                    ? Icons.camera_front
                    : Icons.camera_rear);
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              // Se já estamos processando um código, ignore os próximos.
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                // Marca que estamos processando e para a câmera para evitar re-escanear.
                setState(() {
                  _isProcessing = true;
                });
                await controller.stop();

                final String code = barcodes.first.rawValue!;

                // Garante que o widget ainda está na tela antes de navegar.
                if (mounted) {
                  Navigator.of(context).pop(code);
                }
              }
            },
          ),
          // Overlay para guiar o usuário
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on MobileScannerController {
  get cameraFacingState => null;

  get torchState => null;
}
