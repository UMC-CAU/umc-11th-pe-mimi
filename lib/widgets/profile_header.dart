import 'package:flutter/material.dart';

/// 프로필 이미지, 닉네임, 소개 문구를 세로로 배치하는 헤더.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.nickname,
    required this.bio,
    this.imageAssetPath,
  });

  final String nickname;
  final String bio;

  /// null이면 기본 Icon을 표시한다 (Challenge Mission).
  final String? imageAssetPath;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: colors.primary.withValues(alpha: 0.15),
          backgroundImage:
              imageAssetPath == null ? null : AssetImage(imageAssetPath!),
          child: imageAssetPath == null
              ? Icon(
                  Icons.person,
                  size: 44,
                  color: colors.primary,
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          nickname,
          style: textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          bio,
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
