import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../home/main_shell.dart';
import '../teacher/teacher_dashboard_screen.dart';

enum _Mode { register, login }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _Mode _mode = _Mode.register;
  String _role = 'student';
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    final app = context.read<AppState>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) => app.isTeacher
              ? const TeacherDashboardScreen()
              : const MainShell()),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });

    final app = context.read<AppState>();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (_mode == _Mode.register) {
      final isStudent = _role == 'student';
      final name = isStudent ? _nameCtrl.text.trim() : email.split('@').first;
      if ((isStudent && name.isEmpty) || email.isEmpty || password.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Please fill in every field.';
        });
        return;
      }
      final err = await app.register(
          name: name, email: email, password: password, role: _role);
      if (!mounted) return;
      if (err != null) {
        setState(() {
          _loading = false;
          _error = err;
        });
        return;
      }
      if (app.isLoggedIn) {
        await app.loadProfile();
        if (!mounted) return;
        _goToDashboard();
        return;
      }

      setState(() {
        _loading = false;
        _info =
            'Account created! Please check your email to confirm, then log in.';
        _mode = _Mode.login;
      });
    } else {
      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Please enter your email and password.';
        });
        return;
      }
      final err = await app.login(email: email, password: password);
      if (!mounted) return;
      if (err != null) {
        setState(() {
          _loading = false;
          _error = err;
        });
        return;
      }
      _goToDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = _mode == _Mode.register;

    return Scaffold(
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(gradient: AppColors.skyGradient)),
          const FloatingClouds(count: 3),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 3),
                  Center(
                    child: Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        boxShadow: AppShadows.soft,
                        image: const DecorationImage(
                          image: AssetImage('assets/four.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      alignment: Alignment.center,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                      child: Text(
                          isRegister ? 'Join the Fun!' : 'Welcome Back!',
                          style: AppText.h1)),
                  const SizedBox(height: 4),
                  Center(
                      child: Text(
                          isRegister
                              ? 'Create an account to start playing'
                              : 'Log in to continue learning',
                          style: AppText.bodyMuted)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: AppShadows.soft),
                    child: Row(
                      children: [
                        Expanded(
                            child: _ToggleTab(
                                label: 'Register',
                                selected: isRegister,
                                onTap: () => setState(() {
                                      _mode = _Mode.register;
                                      _error = null;
                                      _info = null;
                                    }))),
                        Expanded(
                            child: _ToggleTab(
                                label: 'Login',
                                selected: !isRegister,
                                onTap: () => setState(() {
                                      _mode = _Mode.login;
                                      _error = null;
                                      _info = null;
                                    }))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isRegister) ...[
                          Row(
                            children: [
                              Expanded(
                                  child: _RoleChip(
                                      label: 'Student',
                                      emoji: '🎒',
                                      selected: _role == 'student',
                                      onTap: () =>
                                          setState(() => _role = 'student'))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _RoleChip(
                                      label: 'Teacher',
                                      emoji: '👩‍🏫',
                                      selected: _role == 'teacher',
                                      onTap: () =>
                                          setState(() => _role = 'teacher'))),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (_role == 'student') ...[
                            _RoundedField(
                                controller: _nameCtrl,
                                hint: "Child's Name",
                                icon: Icons.badge_rounded),
                            const SizedBox(height: 14),
                          ],
                        ],
                        _RoundedField(
                            controller: _emailCtrl,
                            hint: 'Email',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 14),
                        _RoundedField(
                            controller: _passCtrl,
                            hint: 'Password',
                            icon: Icons.lock_rounded,
                            obscure: true),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(_error!,
                              style: AppText.body.copyWith(
                                  color: AppColors.error, fontSize: 13)),
                        ],
                        if (_info != null) ...[
                          const SizedBox(height: 12),
                          Text(_info!,
                              style: AppText.body.copyWith(
                                  color: AppColors.success, fontSize: 13)),
                        ],
                        const SizedBox(height: 22),
                        BouncyButton(
                          label: isRegister ? 'Create Account' : 'Login',
                          width: double.infinity,
                          gradient: AppColors.successGradient,
                          loading: _loading,
                          onTap: _submit,
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.15, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip(
      {required this.label,
      required this.emoji,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.successGradient : null,
          color: selected ? null : AppColors.bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
              color: selected
                  ? Colors.transparent
                  : AppColors.muted.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(label,
                style: AppText.body.copyWith(
                    color: selected ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleTab(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryButtonGradient : null,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppText.body.copyWith(
              color: selected ? Colors.white : AppColors.muted,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  const _RoundedField(
      {required this.controller,
      required this.hint,
      required this.icon,
      this.obscure = false,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: AppText.body,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.blue),
        filled: true,
        fillColor: AppColors.bg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none),
      ),
    );
  }
}
