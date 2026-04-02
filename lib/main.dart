import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'view_models/auth_viewmodel.dart';
import 'view_models/task_viewmodel.dart';
import 'view_models/analytics_viewmodel.dart';
import 'view_models/settings_viewmodel.dart';
import 'view_models/theme_viewmodel.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/home/home_screen.dart';
import 'views/screens/splash/splash_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://eajdvrukcjkkfcjaxqeb.supabase.co',
      anonKey: 'sb_publishable_vfmWmfQz5w_91mGasyrzLw_4y0KLZ9k');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => AnalyticsViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, child) => MaterialApp(
          title: 'LoopMind',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeVM.currentMode,
          onGenerateRoute: AppRoutes.generateRoute,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C3AED), // Flowy violet academic
      brightness: Brightness.light,
    );
    return base.copyWith(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        secondary: const Color(0xFF06B6D4), // Cyan flow
        tertiary: const Color(0xFFFCD34D), // Gold accent
        surface: const Color(0xFFFAF5FF), // Soft lavender surface
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C3AED),
      brightness: Brightness.dark,
    );
    return base.copyWith(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        secondary: const Color(0xFF0EA5E9),
        tertiary: const Color(0xFFEAB308),
        surface: const Color(0xFF1E1B4B), // Dark purple surface
        onSurface: Colors.white70,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
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
