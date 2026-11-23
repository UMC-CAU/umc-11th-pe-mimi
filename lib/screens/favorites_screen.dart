import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/load_phase.dart';
import '../widgets/movielog_button.dart';
import '../widgets/tmdb_poster_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.onOpenMovie});

  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoritesViewModel>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 즐겨찾기'), centerTitle: true),
      body: Consumer<FavoritesViewModel>(
        builder: (context, vm, _) {
          // 로딩
          if (vm.phase == LoadPhase.idle || vm.phase == LoadPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          // 빈 목록
          if (vm.phase == LoadPhase.empty) {
            return const Center(child: Text('아직 즐겨찾기한 영화가 없습니다.'));
          }
          // 목록 조회 전체 실패
          if (vm.phase == LoadPhase.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(vm.errorMessage ?? '조회 오류입니다.'),
                  const SizedBox(height: 12),
                  MovieLogButton(label: '다시 시도', onPressed: vm.refresh),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: vm.refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: vm.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = vm.items[index];
                final movie = item.movie;

                // 영화 정보 한 건만 실패: placeholder + 재조회
                if (movie == null) {
                  return ListTile(
                    leading: const SizedBox(
                      width: 48,
                      height: 72,
                      child: Icon(Icons.broken_image_outlined),
                    ),
                    title: Text('TMDB #${item.favorite.movieId}'),
                    subtitle: Text(item.errorMessage ?? '정보가 없습니다.'),
                    trailing: MovieLogButton(
                      width: 110,
                      label: '정보 재조회',
                      onPressed: vm.refresh,
                    ),
                  );
                }

                final date = movie.releaseDate;
                final year = (date != null && date.length >= 4) ? date.substring(0, 4) : '';

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TmdbPosterImage(posterPath: movie.posterPath, width: 48, height: 72),
                  ),
                  title: Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(year),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await widget.onOpenMovie(movie);
                    if (!mounted) return;
                    await vm.refresh(); // 상세에서 해제하고 돌아오면 목록 갱신
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}