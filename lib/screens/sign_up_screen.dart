import 'package:flutter/material.dart';

import '../widgets/common_app_bar.dart';
import '../widgets/sign_up_header.dart';
import '../widgets/sign_up_submit_button.dart';
import '../widgets/terms_checkbox.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _agreedToTerms = false;

  String? _nicknameErrorText;
  bool _nicknameTouched = false;

  String? _emailErrorText;
  bool _emailTouched = false;

  String? _passwordErrorText;
  bool _passwordTouched = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateNickname(String? value) {
    final nickname = value?.trim() ?? '';

    if (nickname.isEmpty) {
      return '닉네임을 입력해주세요';
    }
    if (nickname.length < 2) {
      return '닉네임은 두 글자 이상 입력해주세요';
    }
    return null;
  }

  void _onNicknameChanged(String value) {
    setState(() {
      _nicknameTouched = true;
      _nicknameErrorText = _validateNickname(value);
    });
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return '이메일을 입력해주세요';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return '유효한 이메일 주소를 입력해주세요';
    }
    return null;
  }

  void _onEmailChanged(String value) {
    setState(() {
      _emailTouched = true;
      _emailErrorText = _validateEmail(value);
    });
  }

  // 비밀번호 검증: 8자 이상인지 확인
  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (password.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다';
    }
    return null;
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordTouched = true;
      _passwordErrorText = _validatePassword(value);
    });
  }

  void _onTermsChanged(bool? value) {
    setState(() {
      _agreedToTerms = value ?? false;
    });
  }

  void _onSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // 가입 버튼 활성화: 4가지 검증이 모두 통과해야 true.
    final canSubmit = _validateNickname(_nicknameController.text) == null &&
        _validateEmail(_emailController.text) == null &&
        _validatePassword(_passwordController.text) == null &&
        _agreedToTerms;

    return Scaffold(
      appBar: const CommonAppBar(title: '회원가입'),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SignUpHeader(),
                const SizedBox(height: 24),

                // 닉네임 TextFormField 
                TextFormField(
                  controller: _nicknameController,
                  onChanged: _onNicknameChanged,
                  validator: _validateNickname,
                  decoration: InputDecoration(
                    labelText: '닉네임',
                    hintText: '2자 이상 입력해주세요',
                    errorText: _nicknameTouched ? _nicknameErrorText : null,
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                // 이메일 TextFormField
                TextFormField(
                  controller: _emailController,
                  onChanged: _onEmailChanged,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  decoration: InputDecoration(
                    labelText: '이메일',
                    hintText: 'movie@example.com',
                    errorText: _emailTouched ? _emailErrorText : null,
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                // 비밀번호 TextFormField
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  onChanged: _onPasswordChanged,
                  validator: _validatePassword,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '영문, 숫자 포함 8자 이상',
                    errorText: _passwordTouched ? _passwordErrorText : null,
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 8),

                TermsCheckbox(
                  value: _agreedToTerms,
                  onChanged: _onTermsChanged,
                ),

                const SizedBox(height: 16),

                SignUpSubmitButton(
                  canSubmit: canSubmit,
                  onSubmit: _onSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}