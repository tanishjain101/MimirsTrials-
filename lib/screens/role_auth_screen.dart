import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_panel_provider.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../utils/role_colors.dart';
import '../widgets/animated_button.dart';
import '../widgets/game_scaffold.dart';

class RoleAuthScreen extends StatefulWidget {
  final UserRole role;
  final String title;
  final String subtitle;
  final Color accentColor;
  final LinearGradient headerGradient;
  final IconData icon;
  final String successRoute;

  const RoleAuthScreen({
    super.key,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.headerGradient,
    required this.icon,
    required this.successRoute,
  });

  @override
  State<RoleAuthScreen> createState() => _RoleAuthScreenState();
}

class _RoleAuthScreenState extends State<RoleAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const topPadding = 32.0;
          const bottomPadding = 24.0;
          const horizontalPadding = 24.0;
          final minHeight = constraints.maxHeight - topPadding - bottomPadding;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              horizontalPadding,
              topPadding,
              horizontalPadding,
              bottomPadding,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildForm(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: widget.headerGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              size: 48,
              color: widget.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (_isSignUp) ...[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value == null || !value.contains('@')
                      ? 'Enter a valid email'
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) =>
                  value == null || value.length < 6
                      ? 'Use at least 6 characters'
                      : null,
            ),
            const SizedBox(height: 20),
            AnimatedButton(
              onPressed: _isLoading ? null : () => _submit(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _isSignUp ? 'Create Account' : 'Login',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () => setState(() => _isSignUp = !_isSignUp),
              child: Text(
                _isSignUp
                    ? 'Already have an account? Login'
                    : 'Need an account? Sign up',
                style: const TextStyle(color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    final success = _isSignUp
        ? await authProvider.signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
            role: widget.role,
          )
        : await authProvider.signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            role: widget.role,
          );

    if (!context.mounted) return;
    if (success && authProvider.currentUser != null) {
      userProvider.setUser(authProvider.currentUser!);
      context.read<AdminPanelProvider>().registerUser(authProvider.currentUser!);
      Navigator.pushReplacementNamed(context, widget.successRoute);
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed. Try again.'),
        ),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}

class TeacherAuthScreen extends StatelessWidget {
  const TeacherAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleAuthScreen(
      role: UserRole.teacher,
      title: 'Teacher Portal',
      subtitle: 'Publish lessons, quizzes, and guide progress.',
      accentColor: TeacherColors.accent,
      headerGradient: TeacherColors.heroGradient,
      icon: Icons.school,
      successRoute: '/teacher-home',
    );
  }
}

class AdminAuthScreen extends StatelessWidget {
  const AdminAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleAuthScreen(
      role: UserRole.admin,
      title: 'Admin Console',
      subtitle: 'Manage content, reports, and platform settings.',
      accentColor: AdminColors.accent,
      headerGradient: AdminColors.heroGradient,
      icon: Icons.admin_panel_settings,
      successRoute: '/admin-home',
    );
  }
}
