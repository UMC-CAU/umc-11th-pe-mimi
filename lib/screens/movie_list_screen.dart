import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/view_state.dart';
import '../widgets/genre_chips.dart';
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
    final viewModel = context.watch<MovieListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('영화'),
        actions: [
          IconButton(onPressed: _openSortSheet, icon: const Icon(Icons.sort)),
        ],
      ),
      body: Column(
        children: [
          GenreChips(
            genres: viewModel.genres,
            selectedId: viewModel.selectedGenreId,
            enabled: !viewModel.isLoading,
            onSelected: (id) => context.read<MovieListViewModel>().selectGenre(id),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (viewModel.state) {
              ViewState.loading => const Center(child: CircularProgressIndicator()),
              ViewState.error => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(viewModel.errorMessage ?? '오류가 발생했어요.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.read<MovieListViewModel>().loadMovies(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ViewState.empty => const Center(child: Text('이 장르의 영화가 없어요.')),
              ViewState.success => _MovieGrid(movies: _sorted(viewModel.movies)),
            },
          ),
        ],
      ),
    );
  }
}

class _MovieGrid extends StatelessWidget {
  const _MovieGrid({required this.movies});

  final List<TmdbMovieDto> movies;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: movies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemBuilder: (context, index) => TmdbMovieCard(movie: movies[index]),
    );
  }
}