import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/projects_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/profile_page.dart';
import 'services/realtime_service.dart';    // <--- just import, don't redefine

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final rt = RealtimeService();
  runApp(
    ProviderScope(
      overrides: [
        realtimeServiceProvider.overrideWithValue(rt),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini-Trello',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/':        (_) => const LoginPage(),
        '/signup':  (_) => const SignupPage(),
        '/home':    (_) => const DashboardPage(),
        '/projects':(_) => const ProjectsPage(),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}
