import 'package:flutter/material.dart';

import '../../config/env.dart';
import '../../core/auth/auth_bootstrap.dart';
import '../../core/auth/auth_facade.dart';
import '../../domain/entities/index.dart';
import '../routes/app_router.dart';

class AuthPlaceholderPage extends StatefulWidget {
  const AuthPlaceholderPage({super.key});

  @override
  State<AuthPlaceholderPage> createState() => _AuthPlaceholderPageState();
}

class _AuthPlaceholderPageState extends State<AuthPlaceholderPage> {
  final TextEditingController _emailController = TextEditingController(
    text: 'demo@marketplace.local',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'password123',
  );

  late final AuthFacade _authFacade;
  bool _useRemote = false;
  bool _isRegisterMode = false;
  bool _isLoading = false;
  String? _errorMessage;
  Auth? _currentAuth;

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
    super.dispose();
  }

  Future<void> _loadSession() async {
    final current = await _authFacade.getCurrentSession(useRemote: _useRemote);
    if (!mounted) {
      return;
    }
    setState(() {
      _currentAuth = current;
    });
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

      final auth = _isRegisterMode
          ? await _authFacade.register(
              name: email.split('@').first,
              email: email,
              password: password,
              useRemote: _useRemote,
            )
          : await _authFacade.login(
              email: email,
              password: password,
              useRemote: _useRemote,
            );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentAuth = auth;
      });

      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _skipToMain() async {
    await _authFacade.useDemoSession();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backendUrl = Env.backendUrl;
    final backendWarning = Env.usesMongoConnectionString
        ? 'MongoDB URIs cannot be called directly from Flutter. Point AUTH_API_URL or API_BASE_URL to your HTTP backend.'
        : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FB),
              Color(0xFFE8F1FF),
              Color(0xFFFDFDFD),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A1F6FEB),
                        blurRadius: 32,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Local Friendly Marketplace',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Auth placeholder powered by domain use cases',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _isRegisterMode
                            ? 'Create a demo account'
                            : 'Sign in to continue',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Switch between demo mode and real backend mode without changing this screen.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.black54,
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _StatusChip(
                              label: _useRemote ? 'Remote mode' : 'Demo mode'),
                          _StatusChip(
                            label: backendUrl == 'https://api.example.com'
                                ? 'Backend pending'
                                : 'Backend configured',
                          ),
                          const _StatusChip(label: 'Domain use cases'),
                        ],
                      ),
                      if (backendWarning != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          backendWarning,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFFC62828),
                                  ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _useRemote,
                        onChanged: (value) async {
                          if (value && Env.usesMongoConnectionString) {
                            setState(() {
                              _errorMessage =
                                  'Set AUTH_API_URL/API_BASE_URL to an HTTP backend. Flutter cannot talk to MongoDB directly.';
                            });
                            return;
                          }
                          setState(() {
                            _useRemote = value;
                          });
                          await _loadSession();
                        },
                        title: const Text('Use remote API'),
                        subtitle: Text(
                          _useRemote
                              ? 'Calls your backend through the auth repository'
                              : 'Uses a demo session so the app works before backend is ready',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'demo@marketplace.local',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: '••••••••',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _errorMessage == null
                            ? const SizedBox.shrink()
                            : Container(
                                key: ValueKey(_errorMessage),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDECEC),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style:
                                      const TextStyle(color: Color(0xFFC62828)),
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.5),
                              )
                            : Text(_isRegisterMode
                                ? 'Create account'
                                : 'Continue to app'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isRegisterMode = !_isRegisterMode;
                                  _errorMessage = null;
                                });
                              },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _isRegisterMode
                              ? 'Switch to sign in'
                              : 'Switch to register',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isLoading ? null : _skipToMain,
                        child: const Text('Skip to dashboard preview'),
                      ),
                      if (_currentAuth != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Session ready for ${_currentAuth!.user.name}',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.black54,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      side: BorderSide.none,
      backgroundColor: Colors.white,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
