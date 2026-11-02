import 'package:flutter/material.dart';

class SignUpSubmitButton extends StatelessWidget {
  const SignUpSubmitButton({
    super.key,
    required this.canSubmit,
    required this.onSubmit,
  });

  final bool canSubmit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: canSubmit ? onSubmit : null,
      child: const Text('가입하기'),
    );
  }
}