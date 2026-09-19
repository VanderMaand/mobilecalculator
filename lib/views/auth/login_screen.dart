import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../widgets/app_widgets.dart';
import 'auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AppController appC = Get.find();

  bool _obscure = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (appC.isLoggedIn.value) {
      Future.microtask(() => Get.offAllNamed('/main'));
    }

    return Scaffold(
      body: PageBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHero(
                      title: 'Login Game Studio',
                      subtitle: 'Masuk untuk mengelola aset & tool produksi',
                    ),
                    const SizedBox(height: 28),
                    AuthCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _username,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Username wajib diisi'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Password wajib diisi'
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Get.snackbar(
                                  'Info',
                                  'Gunakan akun yang sudah didaftarkan. Akun default: admin / admin',
                                  duration: const Duration(seconds: 4),
                                ),
                                child: const Text(
                                  'Lupa password?',
                                  style: TextStyle(color: kPrimary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GradientButton(
                              loading: _loading,
                              label: 'LOGIN',
                              icon: Icons.login,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Belum punya akun?',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                TextButton(
                                  onPressed: _loading
                                      ? null
                                      : () => Get.toNamed('/register'),
                                  child: const Text(
                                    'Daftar',
                                    style: TextStyle(
                                      color: kPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await appC.login(_username.text, _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
  }
}