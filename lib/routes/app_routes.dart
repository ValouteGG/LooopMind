import 'package:flutter/material.dart';
import '../views/screens/auth/login_screen.dart';
import '../views/screens/auth/signup_screen.dart';
import '../views/screens/home/home_screen.dart';
import '../views/screens/tasks/create_task_screen.dart';
import '../views/screens/tasks/task_detail_screen.dart';
import '../views/screens/analytics/analytics_screen.dart';
import '../views/screens/profile/profile_screen.dart';
import '../views/screens/profile/edit_profile_screen.dart';
import '../views/screens/profile/about_screen.dart';
import '../views/screens/chat/chat_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String createTask = '/create-task';
  static const String taskDetail = '/task-detail';
  static const String analytics = '/analytics';
  static const String profile = '/profile';
  static const String chat = '/chat';
  static const String editProfile = '/edit-profile';
  static const String about = '/about';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case createTask:
        return MaterialPageRoute(builder: (_) => const CreateTaskScreen());
      case taskDetail:
        final args = settings.arguments as Map<String, dynamic>;
        final String taskId = args['id'] as String;
        final String mode = args['mode'] as String? ?? 'view';
        return MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskId: taskId, mode: mode),
        );
      case analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
