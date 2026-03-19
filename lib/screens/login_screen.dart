import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_panel_provider.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../widgets/animated_button.dart';
import '../widgets/game_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _isLoading = false;

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/WhatsApp Image 2026-03-16 at 09.50.18.jpeg',
              width: 110,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'MimirsTrials',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Conquer the Trials. Master the Code.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
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
                  gradient: AppColors.primaryGradient,
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
            const SizedBox(height: 12),
            AnimatedButton(
              onPressed: _isLoading ? null : () => _googleSignIn(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.navBorder),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.g_mobiledata, color: AppColors.text, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Continue with Google',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() => _isSignUp = !_isSignUp);
                    },
              child: Text(
                _isSignUp
                    ? 'Already have an account? Login'
                    : 'New here? Create an account',
                style: const TextStyle(color: AppColors.textLight),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Are you a teacher or admin?',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pushNamed(context, '/teacher-auth'),
                  child: const Text('Teacher Portal'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pushNamed(context, '/admin-auth'),
                  child: const Text('Admin Portal'),
                ),
              ],
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
          )
        : await authProvider.signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

    if (!context.mounted) return;
    if (success && authProvider.currentUser != null) {
      userProvider.setUser(authProvider.currentUser!);
      context.read<AdminPanelProvider>().registerUser(authProvider.currentUser!);
      Navigator.pushReplacementNamed(context, '/home');
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

  Future<void> _googleSignIn(BuildContext context) async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final success = await authProvider.signInWithGoogle();
    if (!context.mounted) return;
    if (success && authProvider.currentUser != null) {
      userProvider.setUser(authProvider.currentUser!);
      context.read<AdminPanelProvider>().registerUser(authProvider.currentUser!);
      Navigator.pushReplacementNamed(context, '/home');
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(authProvider.error ?? 'Google sign-in failed. Try again.'),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}
