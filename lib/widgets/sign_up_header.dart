import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MovieLog 시작하기', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          '닉네임을 먼저 정해주세요',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
        ),
      ],
    );
  }
}