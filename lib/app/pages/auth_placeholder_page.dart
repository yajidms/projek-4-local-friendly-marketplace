import 'package:flutter/material.dart';

import '../../config/env.dart';
import '../../core/auth/auth_bootstrap.dart';
import '../../core/auth/auth_facade.dart';
import '../../core/auth/role_router.dart';
import '../../domain/entities/index.dart';
import '../routes/app_router.dart';

class AuthPlaceholderPage extends StatefulWidget {
  const AuthPlaceholderPage({super.key});

  @override
  State<AuthPlaceholderPage> createState() => _AuthPlaceholderPageState();
}

class _AuthPlaceholderPageState extends State<AuthPlaceholderPage> {
  final TextEditingController _emailController = TextEditingController(
    text: '',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '',
  );
  final TextEditingController _phoneController = TextEditingController();

  late final AuthFacade _authFacade;
  bool _useRemote = false;
  bool _isLoading = false;
  String? _errorMessage;
  Auth? _currentAuth;
  bool _usePhoneLogin = false;

  @override
  void initState() {
    super.initState();
    _authFacade = AuthBootstrap.build();
    _useRemote = Env.hasConfiguredBackendUrl && !Env.usesMongoConnectionString;
    _loadSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    final current = await _authFacade.getCurrentSession(useRemote: _useRemote);
    if (!mounted) return;
    if (current != null) {
      RoleRouter.navigateAfterLogin(context, current.user);
      return;
    }
    setState(() => _currentAuth = current);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final auth = await _authFacade.login(
        email: email,
        password: password,
        useRemote: _useRemote,
      );

      if (!mounted) return;

      setState(() => _currentAuth = auth);
      RoleRouter.navigateAfterLogin(context, auth.user);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _skipToMain() async {
    await _authFacade.useDemoSession();
    if (!mounted) return;
    final session = await _authFacade.getCurrentSession(useRemote: _useRemote);
    if (!mounted || session == null) return;
    RoleRouter.navigateAfterLogin(context, session.user);
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
                    'Local Friendly\nMarketplace',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk untuk menikmati belanja',
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
                        style: const TextStyle(color: Color(0xFFC62828), fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _usePhoneLogin ? _phoneController : _emailController,
                    keyboardType: _usePhoneLogin ? TextInputType.phone : TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: _usePhoneLogin ? 'Nomor Telepon' : 'Email',
                      hintText: _usePhoneLogin ? '08123456789' : 'nama@email.com',
                      prefixIcon: Icon(
                        _usePhoneLogin ? Icons.phone_android_rounded : Icons.email_outlined,
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
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FDF9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.green),
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
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FDF9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur reset kata sandi belum tersedia')),
                        );
                      },
                      child: Text(
                        'Lupa Kata Sandi',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                            'Masuk',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFE8F5E9))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'atau masuk dengan',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.black45),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFE8F5E9))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _usePhoneLogin = !_usePhoneLogin;
                        _errorMessage = null;
                      });
                    },
                    icon: Icon(
                      _usePhoneLogin ? Icons.email_outlined : Icons.phone_android_rounded,
                      color: Colors.green.shade700,
                    ),
                    label: Text(
                      _usePhoneLogin ? 'Masuk dengan Email' : 'Masuk dengan Nomor Telepon',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: BorderSide(color: Colors.green.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur login Google belum tersedia')),
                      );
                    },
                    icon: Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    label: Text(
                      'Masuk dengan Google',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: BorderSide(color: Colors.green.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _skipToMain,
                    child: Text(
                      'Lewati ke halaman utama',
                      style: TextStyle(color: Colors.green.shade400),
                    ),
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
