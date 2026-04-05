import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/theme_viewmodel.dart';
import '../../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.1,
    ).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Staggered animations
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      _slideController.forward();
    });

    _navigateToApp();
  }

  Future<void> _navigateToApp() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.login,
        arguments: {'fromSplash': true}, // Signal smooth transition
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFF7C3AED),
                Color(0xFF06B6D4),
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Center(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 60),
                            const Text(
                              'LoopMind',
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 6),
                                    blurRadius: 12,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Academic Flow',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white.withOpacity(0.98),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Animated loading at bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
