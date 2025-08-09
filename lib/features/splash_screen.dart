import 'package:bus_attendance_app/features/auth/auth_gate.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _lineAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(_lineController);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(seconds: 3));

    _gradientController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const AuthGate(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  @override
  void dispose() {
    _lineController.dispose();
    _fadeController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double lineAnimationHeight = screenHeight * 0.8;
    final double lineAreaTop = screenHeight * 0.5;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          final double t = _gradientController.value;
          final List<Color> gradientColors = [
            Color.lerp(Colors.black, const Color(0xFFB06DF9), t)!,
            Color.lerp(Colors.black, const Color(0xFF828EF3), t)!,
            Color.lerp(Colors.black, const Color(0xFF84CFB2), t)!,
            Color.lerp(Colors.black, const Color(0xFFCAFF5C), t)!,
          ];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
                stops: const [0.0, 0.33, 0.66, 1.0],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: screenHeight * 0.35,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Image.asset(
                      'assets/images/logo-texto-image.png',
                      width: screenWidth * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                Positioned(
                  top: lineAreaTop,
                  height: lineAnimationHeight,
                  width: screenWidth,
                  child: ClipRect(
                    child: AnimatedBuilder(
                      animation: _lineAnimation,
                      builder: (context, child) {
                        final double travelRange = lineAnimationHeight * 1.5;
                        final double currentY =
                            _lineAnimation.value * travelRange -
                            (travelRange / 2);

                        const double lineHeight = 80;
                        const double lineWidth = 8;
                        const double lineSpacing = 150;

                        List<Widget> lines = [];
                        final int numberOfLines =
                            (lineAnimationHeight / lineSpacing).ceil() + 3;

                        for (int i = 0; i < numberOfLines; i++) {
                          final double individualLineY =
                              currentY + (i * lineSpacing);

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
                                      borderRadius: BorderRadius.circular(0),
                                      boxShadow: [
                                        BoxShadow(
                                          // ignore: deprecated_member_use
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
        },
      ),
    );
  }

  double _getLineOpacity(double yPos, double containerHeight) {
    const double fadeZoneHeight = 200;

    double opacity = 1.0;

    if (yPos < fadeZoneHeight) {
      opacity = yPos / fadeZoneHeight;
    } else if (yPos > containerHeight - fadeZoneHeight) {
      opacity = (containerHeight - yPos) / fadeZoneHeight;
    }

    return opacity.clamp(0.0, 1.0);
  }
}
