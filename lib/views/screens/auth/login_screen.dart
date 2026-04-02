import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/auth_viewmodel.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/oauth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Welcome Back',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Continue your learning journey',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    if (authVM.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          authVM.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (authVM.error != null) const SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'demo@loopmind.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Email is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'password123',
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          return 'Password is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      text: authVM.isLoading ? 'Logging in...' : 'Login',
                      isLoading: authVM.isLoading,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await authVM.login(
                            _emailController.text,
                            _passwordController.text,
                          );
                          if (success && mounted) {
                            Navigator.of(context).pushReplacementNamed('/home');
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // OAuth Buttons
                    Column(
                      children: [
                        OAuthButton(
                          icon: Icons.g_mobiledata,
                          label: 'Continue with Google',
                          onPressed: () => context
                              .read<AuthViewModel>()
                              .signInWithOAuth('google'),
                        ),
                        const SizedBox(height: 12),
                        OAuthButton(
                          icon: Icons.facebook,
                          label: 'Continue with Facebook',
                          onPressed: () => context
                              .read<AuthViewModel>()
                              .signInWithOAuth('facebook'),
                        ),
                        const SizedBox(height: 12),
                        OAuthButton(
                          icon: Icons.code,
                          label: 'Continue with GitHub',
                          onPressed: () => context
                              .read<AuthViewModel>()
                              .signInWithOAuth('github'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
