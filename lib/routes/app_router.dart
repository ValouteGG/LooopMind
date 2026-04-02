import 'package:flutter/material.dart';
import '../views/auth_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoopMind',
      theme: ThemeData(),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthChecker(),
        '/auth': (context) => const AuthScreen(),
        '/signin': (context) => const AuthScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      // if there is no session, show the authentication screen
      return const AuthScreen();
    } else {
      // if there is a session, show the phonebook screen
      return const Scaffold(
        body: Center(child: Text('Phonebook Screen Placeholder')),
      );
    }
  }
}
