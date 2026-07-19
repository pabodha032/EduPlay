import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/teacher/teacher_dashboard_screen.dart';

const _supabaseUrl = 'https://pokxwgorlzqokgotfted.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBva3h3Z29ybHpxb2tnb3RmdGVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzNjM5MzcsImV4cCI6MjA5OTkzOTkzN30.jiZW8lCXOtN3H2xFnpOhJ5PqCMnphapjElesqktuvNQ';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  runApp(const EduPlayApp());
}

class EduPlayApp extends StatelessWidget {
  const EduPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'EduPlay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await context.read<AppState>().loadProfile();
    }
    if (!mounted) return;
    setState(() {
      _loggedIn = session != null;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
          backgroundColor: AppColors.bg,
          body: Center(child: CircularProgressIndicator()));
    }
    if (!_loggedIn) return const SplashScreen();
    final app = context.watch<AppState>();
    return app.isTeacher ? const TeacherDashboardScreen() : const MainShell();
  }
}
