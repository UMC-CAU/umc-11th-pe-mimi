import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/profile_stat.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/edit_profile_button.dart';
import '../widgets/favorite_genres.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';

/// 1주차 미션: MovieLog "내 프로필" 화면.
/// 화면 전환이나 입력 기능 없이 정적인 UI만 구현한다.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _stats = [
    ProfileStat(label: '본 영화', value: '342'),
    ProfileStat(label: '평점', value: '4.2'),
    ProfileStat(label: '즐겨찾기', value: '58'),
  ];

  static const _genres = ['드라마', 'SF', '애니메이션'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CommonAppBar(title: '내 프로필'),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/logos/movielog_logo.svg',
                  width: 48,
                  height: 48,
                  colorFilter: ColorFilter.mode(
                    colors.primary,
                    BlendMode.srcIn,
                  ),
                  semanticsLabel: 'MovieLog 로고',
                ),
              ),
              const SizedBox(height: 24),
              const ProfileHeader(
                nickname: '무비러버',
                bio: '매주 주말엔 영화관으로 출근하는 프로 관람객. '
                    '좋은 영화를 보고 기록하는 것을 좋아합니다.',
              ),
              const SizedBox(height: 20),
              const EditProfileButton(),
              const SizedBox(height: 24),
              const ProfileStats(stats: _stats),
              const SizedBox(height: 24),
              const Text(
                '선호하는 장르',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const FavoriteGenres(genres: _genres),
            ],
          ),
        ),
      ),
    );
  }
}
