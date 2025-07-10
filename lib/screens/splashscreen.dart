import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Uber Splash Screen',
      debugShowCheckedModeBanner: false, // Oculta o banner de debug
      home: SplashScreen(),
    );
  }
}

// Tela de destino após a splash screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo ao Uber'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[900],
      body: const Center(
        child: Text(
          'Seu aplicativo está pronto!',
          style: TextStyle(fontSize: 24, color: Colors.white70),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Duração de um ciclo completo
    )..repeat(); // Faz a animação se repetir infinitamente

    // A animação vai de -1.0 a 1.0 para mapear o movimento vertical
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(_controller);

    // Navega para a próxima tela após um atraso (e.g., 4 segundos)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration:
                const Duration(milliseconds: 800), // duração do fade
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Área onde as linhas irão animar, abaixo do texto "Uber"
    final double lineAnimationHeight =
        screenHeight * 0.8; // Altura da área de animação das linhas
    final double lineAreaTop =
        screenHeight * 0.5; // Posição vertical de início da área de linhas

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: screenHeight * 0.35,
            child: const Text(
              'Uber',
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),

          // Container para as linhas animadas
          Positioned(
            top: lineAreaTop,
            height: lineAnimationHeight,
            width: screenWidth,
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final double travelRange = lineAnimationHeight * 1.5;
                  final double currentY =
                      _animation.value * travelRange - (travelRange / 2);

                  // Propriedades das linhas
                  const double lineHeight =
                      80; // Comprimento de cada segmento de linha
                  const double lineWidth = 5; // Espessura de cada linha
                  const double lineSpacing =
                      150; // Espaçamento vertical entre as linhas que aparecem

                  List<Widget> lines = [];
                  // Adiciona múltiplas linhas para criar um fluxo contínuo
                  final int numberOfLines =
                      (lineAnimationHeight / lineSpacing).ceil() +
                          3; // +3 para garantir linhas fora da tela

                  for (int i = 0; i < numberOfLines; i++) {
                    // Calcula a posição Y de cada linha individualmente
                    final double individualLineY = currentY + (i * lineSpacing);

                    // Opacidade para criar o efeito de "passando" (fade in/out)
                    final double opacity = _getLineOpacity(
                      individualLineY,
                      lineAnimationHeight,
                    );

                    if (opacity > 0) {
                      lines.add(
                        Positioned(
                          top: individualLineY,
                          left: (screenWidth - lineWidth) / 2,
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: lineWidth,
                              height: lineHeight,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  return Stack(children: lines);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getLineOpacity(double yPos, double containerHeight) {
    const double fadeZoneHeight =
        200; // Distância em pixels das bordas para começar o fade

    double opacity = 1.0;

    // Fade-in na parte superior
    if (yPos < fadeZoneHeight) {
      opacity = yPos / fadeZoneHeight;
    }
    // Fade-out na parte inferior
    else if (yPos > containerHeight - fadeZoneHeight) {
      opacity = (containerHeight - yPos) / fadeZoneHeight;
    }

    return opacity.clamp(
        0.0, 1.0); // Garante que a opacidade esteja entre 0 e 1
  }
}
