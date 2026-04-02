import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:provider/provider.dart';
import '../../../view_models/auth_viewmodel.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/oauth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _formFade;

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

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Staggered animations matching splash
    Future.delayed(
        const Duration(milliseconds: 400), () => _scaleController.forward());
    Future.delayed(
        const Duration(milliseconds: 800), () => _fadeController.forward());
    Future.delayed(
        const Duration(milliseconds: 1200), () => _slideController.forward());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Consumer<AuthViewModel>(
          builder: (context, authVM, _) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    // Animated title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Welcome',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 4),
                                      blurRadius: 16,
                                      color: Color(0xFF000000),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Continue your learning journey',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white.withOpacity(0.95),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Glassmorphism form card
                    FadeTransition(
                      opacity: _formFade,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(36),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.12),
                              blurRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.25),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  if (authVM.error != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(2),
                                        border: Border.all(
                                            color: Colors.red.withOpacity(0.4)),
                                      ),
                                      child: Text(
                                        authVM.error!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                  CustomTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    hintText: 'demo@loopmind.com',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Email is required';
                                      if (!value.contains('@'))
                                        return 'Please enter valid email';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  CustomTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    hintText: '••••••••',
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Password is required';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        // Forgot password logic
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: authVM.isLoading
                                          ? null
                                          : () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                final success =
                                                    await authVM.login(
                                                  _emailController.text.trim(),
                                                  _passwordController.text,
                                                );
                                                if (success && mounted) {
                                                  Navigator.of(context)
                                                      .pushReplacementNamed(
                                                          '/home');
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF7C3AED),
                                        foregroundColor: Colors.white,
                                        elevation: 8,
                                        shadowColor: const Color(0xFF7C3AED)
                                            .withOpacity(0.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      child: authVM.isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (!authVM.isLoading) ...[
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.3))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.3))),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Column(
                        children: [
                          OAuthButton(
                            icon: Icons.g_mobiledata,
                            label: 'Continue with Google',
                            onPressed: () => context
                                .read<AuthViewModel>()
                                .signInWithOAuth('google'),
                          ),
                          const SizedBox(height: 16),
                          OAuthButton(
                            icon: Icons.facebook,
                            label: 'Continue with Facebook',
                            onPressed: () => context
                                .read<AuthViewModel>()
                                .signInWithOAuth('facebook'),
                          ),
                          const SizedBox(height: 16),
                          OAuthButton(
                            icon: Icons.code,
                            label: 'Continue with GitHub',
                            onPressed: () => context
                                .read<AuthViewModel>()
                                .signInWithOAuth('github'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.of(context).pushNamed('/signup'),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
