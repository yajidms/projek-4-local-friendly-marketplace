import 'package:flutter/material.dart';

import '../../app/routes/app_router.dart';
import '../../config/env.dart';
import '../../core/auth/auth_bootstrap.dart';
import '../../core/auth/auth_facade.dart';
import '../../core/auth/role_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  late final AuthFacade _authFacade;
  bool get _useRemote =>
      Env.hasConfiguredBackendUrl && !Env.usesMongoConnectionString;

  @override
  void initState() {
    super.initState();
    _authFacade = AuthBootstrap.build();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text;

      if (name.isEmpty) {
        throw Exception('Nama lengkap harus diisi');
      }
      if (email.isEmpty) {
        throw Exception('Email harus diisi');
      }
      if (password.length < 6) {
        throw Exception('Kata sandi minimal 6 karakter');
      }

      final auth = await _authFacade.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        useRemote: _useRemote,
      );

      if (!mounted) return;

      RoleRouter.navigateAfterLogin(context, auth.user);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Buat Akun Baru',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Daftar untuk mulai berbelanja',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFC62828),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      hintText: 'Alya Putri',
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.green,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE8F5E9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE8F5E9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FDF9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'nama@email.com',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.green,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE8F5E9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE8F5E9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FDF9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: '+628123456789',
                      prefixIcon: const Icon(
                        Icons.phone_android_rounded,
                        color: Colors.green,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE8F5E9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE8F5E9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FDF9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      hintText: '••••••••',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.green,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.green,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE8F5E9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE8F5E9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FDF9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Masuk',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
