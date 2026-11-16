import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/create_member_request.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movielog_button.dart';
import '../widgets/sign_up_header.dart';
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
  bool _nicknameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // ===== 형식 검사 (서버 규칙과 맞춤) =====
  String? _validateNickname(String? value) {
    final nickname = value?.trim() ?? '';
    if (nickname.isEmpty) return '닉네임을 입력해주세요';
    if (nickname.length < 2 || nickname.length > 12) {
      return '닉네임은 2자 이상 12자 이하로 입력해주세요';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return '이메일을 입력해주세요';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return '유효한 이메일 주소를 입력해주세요';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return '비밀번호를 입력해주세요';
    final passwordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*]).{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      return '대문자/소문자/숫자/특수문자(!@#\$%^&*)를 포함한 8자 이상이어야 합니다';
    }
    return null;
  }

  // 형식 에러가 있으면 형식 에러, 없으면 서버 중복 확인 에러
  String? _nicknameError(SignUpViewModel vm) {
    final formatError = _validateNickname(_nicknameController.text);
    if (_nicknameTouched && formatError != null) return formatError;
    return vm.nicknameErrorText;
  }

  String? _emailError(SignUpViewModel vm) {
    final formatError = _validateEmail(_emailController.text);
    if (_emailTouched && formatError != null) return formatError;
    return vm.emailErrorText;
  }

  // 로컬 형식 에러가 우선, 통과했는데 서버가 거부했으면 서버 메시지
  String? _passwordError(SignUpViewModel vm) {
    final formatError = _validatePassword(_passwordController.text);
    if (_passwordTouched && formatError != null) return formatError;
    return vm.passwordErrorText;
  }

  Future<void> _onSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    FocusScope.of(context).unfocus();

    final viewModel = context.read<SignUpViewModel>();
    await viewModel.submit(
      CreateMemberRequest(
        email: _emailController.text,
        password: _passwordController.text,
        nickname: _nicknameController.text,
      ),
    );
    if (!mounted) return;

    if (viewModel.submitStatus == SubmitStatus.success &&
        viewModel.createdMemberId != null) {
      context.read<LearningMemberSession>().setMemberId(viewModel.createdMemberId!);
      context.go('/home');
      return;
    }

    if (viewModel.snackbarMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.snackbarMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignUpViewModel>();

    final nicknameFormatOk = _validateNickname(_nicknameController.text) == null;
    final emailFormatOk = _validateEmail(_emailController.text) == null;

    final canSubmit = nicknameFormatOk &&
        emailFormatOk &&
        _validatePassword(_passwordController.text) == null &&
        _agreedToTerms &&
        vm.isDuplicateCheckDone &&
        !vm.isSubmitting;

    return PopScope(
      canPop: !vm.isSubmitting, // 제출 중에는 뒤로가기 막기
      child: Scaffold(
        appBar: const CommonAppBar(title: '회원가입'),
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SignUpHeader(),
                  const SizedBox(height: 24),

                  // 닉네임 + 중복 확인 버튼
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nicknameController,
                          validator: _validateNickname,
                          onChanged: (value) {
                            setState(() => _nicknameTouched = true);
                            vm.onNicknameChanged(value);
                          },
                          decoration: InputDecoration(
                            labelText: '닉네임',
                            hintText: '2자 이상 12자 이하',
                            errorText: _nicknameError(vm),
                            helperText: vm.nicknameCheckStatus == CheckStatus.available
                                ? '사용할 수 있는 닉네임입니다.'
                                : null,
                            suffixIcon: vm.nicknameCheckStatus == CheckStatus.available
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: MovieLogButton(
                          label: '중복 확인',
                          isLoading: vm.nicknameCheckStatus == CheckStatus.checking,
                          onPressed: vm.canCheckNickname && nicknameFormatOk
                              ? () => vm.checkNickname(_nicknameController.text)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 이메일 + 중복 확인 버튼
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                          onChanged: (value) {
                            setState(() => _emailTouched = true);
                            vm.onEmailChanged(value);
                          },
                          decoration: InputDecoration(
                            labelText: '이메일',
                            hintText: 'movie@example.com',
                            errorText: _emailError(vm),
                            helperText: vm.emailCheckStatus == CheckStatus.available
                                ? '사용할 수 있는 이메일입니다.'
                                : null,
                            suffixIcon: vm.emailCheckStatus == CheckStatus.available
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: MovieLogButton(
                          label: '중복 확인',
                          isLoading: vm.emailCheckStatus == CheckStatus.checking,
                          onPressed: vm.canCheckEmail && emailFormatOk
                              ? () => vm.checkEmail(_emailController.text)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 비밀번호
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    validator: _validatePassword,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    onChanged: (_) {
                      setState(() => _passwordTouched = true);
                      vm.onPasswordChanged();
                    },
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      hintText: '대/소문자, 숫자, 특수문자 포함 8자 이상',
                      errorText: _passwordError(vm),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  TermsCheckbox(
                    value: _agreedToTerms,
                    onChanged: (value) =>
                        setState(() => _agreedToTerms = value ?? false),
                  ),
                  const SizedBox(height: 16),

                  // 가입하기: 전체 너비
                  MovieLogButton(
                    label: '가입하기',
                    width: double.infinity,
                    isLoading: vm.isSubmitting,
                    onPressed: canSubmit ? _onSubmit : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}