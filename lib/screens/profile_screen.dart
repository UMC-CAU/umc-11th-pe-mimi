import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/profile_stat.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/favorite_genres.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';

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
    final auth = context.watch<AuthViewModel>();
    final member = auth.member;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('내 프로필'),
        actions: [
          IconButton(
            tooltip: '로그아웃',
            icon: const Icon(Icons.logout),
            // 로그아웃만 하면 Router가 상태 보고 /login으로 보냄
            onPressed: auth.storageCleanupInProgress ? null : auth.logout,
          ),
        ],
      ),
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
                  colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
                  semanticsLabel: 'MovieLog 로고',
                ),
              ),
              const SizedBox(height: 24),

              // 8주차: 내 정보 (로딩 / 실패 / 성공)
              if (member != null)
                ProfileHeader(nickname: member.nickname, bio: member.email)
              else if (auth.memberStatus == MemberLoadStatus.error)
                Column(
                  children: [
                    const Text('내 정보를 불러오지 못했어요.'),
                    TextButton(
                      onPressed: () => auth.loadMember(force: true),
                      child: const Text('다시 시도'),
                    ),
                  ],
                )
              else
                const Center(child: CircularProgressIndicator()),

              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: member == null
                    ? null
                    : () => context.push('/my/profile/edit'),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('프로필 수정'),
              ),
              const SizedBox(height: 24),
              const ProfileStats(stats: _stats),
              const SizedBox(height: 24),
              const Text(
                '선호하는 장르',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const FavoriteGenres(genres: _genres),
              const SizedBox(height: 24),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.star_outline, color: colors.primary),
                title: const Text(
                  '내가 등록한 평점',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/my/ratings'),
              ),
              const Divider(),
                            ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.bookmark_outline, color: colors.primary),
                title: const Text(
                  '내 즐겨찾기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right),
                // 내 정보가 준비된 뒤에만 활성화
                enabled: member != null,
                onTap: () => context.push('/my/favorites'),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}