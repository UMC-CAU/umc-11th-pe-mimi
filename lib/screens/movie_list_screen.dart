import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../view_models/load_phase.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/paged_movies_view_model.dart';
import '../widgets/genre_chips.dart';
import '../widgets/movie_page_footer.dart';
import '../widgets/sort_sheet.dart';
import '../widgets/tmdb_movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String _sort = '기본순';

  Future<void> _openSortSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (_) => SortSheet(current: _sort),
    );
    if (result == null || !mounted) return;
    setState(() => _sort = result);
  }

  // 불러온 목록 안에서만 정렬
  List<TmdbMovieDto> _sorted(List<TmdbMovieDto> movies) {
    final list = [...movies];
    if (_sort == '평점 높은순') {
      list.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
    } else if (_sort == '최신순') {
      list.sort((a, b) => (b.releaseDate ?? '').compareTo(a.releaseDate ?? ''));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final genres = context.watch<MovieListViewModel>().genres;
    final vm = context.watch<PagedMoviesViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('영화'),
        actions: [
          IconButton(
            tooltip: '영화 검색',
            onPressed: () => context.push('/movies/search'),
            icon: const Icon(Icons.search),
          ),
          IconButton(onPressed: _openSortSheet, icon: const Icon(Icons.sort)),
        ],
      ),
      body: Column(
        children: [
          GenreChips(
            genres: genres,
            selectedId: vm.genreId,
            enabled: vm.phase != LoadPhase.loading,
            onSelected: (id) {
              if (id == vm.genreId) return;
              // 장르가 바뀌면 이전 목록 비우고 첫 page부터
              context.read<PagedMoviesViewModel>().loadInitial(genreId: id);
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (vm.phase) {
              LoadPhase.idle || LoadPhase.loading =>
                const Center(child: CircularProgressIndicator()),
              LoadPhase.error => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vm.errorMessage ?? '오류가 발생했어요.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => vm.loadInitial(genreId: vm.genreId),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              LoadPhase.empty => const Center(child: Text('이 장르의 영화가 없어요.')),
              LoadPhase.ready => _MovieGrid(movies: _sorted(vm.movies), vm: vm),
            },
          ),
        ],
      ),
    );
  }
}

class _MovieGrid extends StatelessWidget {
  const _MovieGrid({required this.movies, required this.vm});

  final List<TmdbMovieDto> movies;
  final PagedMoviesViewModel vm;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => TmdbMovieCard(movie: movies[index]),
              childCount: movies.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.55,
            ),
          ),
        ),
        // 카드 목록 아래 footer (더 보기 / 재시도 / 끝)
        SliverToBoxAdapter(child: MoviePageFooter(vm: vm)),
      ],
    );
  }
}