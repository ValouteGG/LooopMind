import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'view_models/auth_viewmodel.dart';
import 'view_models/task_viewmodel.dart';
import 'view_models/analytics_viewmodel.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/home/home_screen.dart';

void main() {
  runApp(const LoopMindApp());
}

class LoopMindApp extends StatelessWidget {
  const LoopMindApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => AnalyticsViewModel()),
      ],
      child: MaterialApp(
        title: 'LoopMind',
        theme: _buildTheme(),
        onGenerateRoute: AppRoutes.generateRoute,
        home: const _AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.light,
      ),
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}

class _AuthWrapper extends StatefulWidget {
  const _AuthWrapper({Key? key}) : super(key: key);

  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        if (authVM.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return authVM.isAuthenticated
            ? const HomeScreen()
            : const LoginScreen();
      },
    );
  }
}
