import 'package:flutter/material.dart';

import '../models/pkl_user.dart';
import '../services/supabase_service.dart';
import '../services/user_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.users, required this.onLogin});

  final List<PklUser> users;
  final ValueChanged<PklUser> onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      final input = _usernameController.text.trim().toLowerCase();
      final pass = _passwordController.text;

      PklUser? matchedUser;
      for (final user in widget.users) {
        if ((user.username.toLowerCase() == input ||
                user.accountId.toLowerCase() == input) &&
            user.password == pass) {
          matchedUser = user;
          break;
        }
      }

      if (matchedUser == null && isSupabaseReady) {
        try {
          matchedUser = await UserRepository().login(input, pass);
        } catch (_) {}
      }

      if (matchedUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username/NIP/NISN atau kata sandi tidak sesuai.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      widget.onLogin(matchedUser);
    }
  }

  void _showForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.lock_reset_rounded, color: AppColors.maroon),
        title: const Text('Lupa kata sandi?'),
        content: const Text(
          'Silakan hubungi administrator sekolah untuk melakukan reset kata sandi akun PKLJOURNEY Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maroon,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 24, 26, 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      const BrandMark(light: true, showWordmark: false),
                      const SizedBox(height: 13),
                      Text(
                        'LANGKAH PERTAMAMU',
                        style: TextStyle(
                          color: AppColors.cream.withOpacity(0.72),
                          fontSize: 10,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat Datang',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontSize: 23),
                              ),
                              const SizedBox(height: 7),
                              const Text(
                                'Masuk dan lanjutkan perjalanan PKL-mu.',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 22),
                              const _FieldLabel('USERNAME / NIP / NISN'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  hintText: 'masukkan disini',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'Masukkan username'
                                    : null,
                              ),
                              const SizedBox(height: 18),
                              const _FieldLabel('PASSWORD'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan kata sandi akun',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _obscurePassword
                                        ? 'Tampilkan kata sandi'
                                        : 'Sembunyikan kata sandi',
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Masukkan kata sandi'
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.maroon,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (value) => setState(
                                      () => _rememberMe = value ?? false,
                                    ),
                                  ),
                                  const Text(
                                    'Ingat saya',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _submit,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Masuk'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Center(
                                child: TextButton(
                                  onPressed: _showForgotPassword,
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.maroon,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Lupa password?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Text(
                                  'Demo login: admin/admin • guru/guru • iduka/iduka • murid/murid',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.muted.withOpacity(0.9),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'PKLJOURNEY  •  BIDANG KEAHLIAN REKAYASA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.cream.withOpacity(0.68),
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.taupe,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.9,
      ),
    );
  }
}
