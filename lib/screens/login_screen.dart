import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/auth_view_model.dart';
import '../widgets/movielog_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AuthViewModel _auth;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthViewModel>();
    _auth.addListener(_showSessionExpired);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSessionExpired());
  }

  // 토큰 만료로 쫓겨났을 때만 안내 (직접 로그아웃·로그인 실패는 X)
  void _showSessionExpired() {
    if (!mounted || !_auth.sessionExpired) return;
    _auth.consumeSessionExpired();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('로그인이 만료됐어요. 다시 로그인해 주세요.')),
      );
  }

  @override
  void dispose() {
    _auth.removeListener(_showSessionExpired);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      _auth.login(_email.text.trim(), _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final loading = auth.status == AuthStatus.authenticating;
    final enabled = !loading && !auth.storageCleanupInProgress;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('로그인'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(Icons.movie, size: 72, color: colorScheme.primary),
              const SizedBox(height: 16),
              const Text(
                'MovieLog에 로그인',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _email,
                enabled: enabled,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? '이메일을 입력해 주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                enabled: enabled,
                obscureText: true,
                onFieldSubmitted: (_) => enabled ? _submit() : null,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? '비밀번호를 입력해 주세요.' : null,
              ),
              if (auth.message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    auth.message!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              const SizedBox(height: 32),
              MovieLogButton(
                label: '로그인',
                width: double.infinity,
                isLoading: loading,
                onPressed: enabled ? _submit : null,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: enabled ? () => context.push('/register') : null,
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}