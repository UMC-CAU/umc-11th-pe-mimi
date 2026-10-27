import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        const Expanded(
          child: Text('필수 약관에 동의합니다', style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }
}