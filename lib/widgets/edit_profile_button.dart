import 'package:flutter/material.dart';

/// 프로필 수정 버튼. 모양만 구현하며 화면 이동이나 입력 기능은 넣지 않는다.
class EditProfileButton extends StatelessWidget {
  const EditProfileButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('프로필 수정'),
    );
  }
}
