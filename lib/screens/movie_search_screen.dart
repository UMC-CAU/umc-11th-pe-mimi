import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../view_models/load_phase.dart';
import '../view_models/paged_movies_view_model.dart';
import '../widgets/movie_page_footer.dart';
import '../widgets/movielog_button.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key, required this.onOpenMovie});

  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final _text = TextEditingController();
  String _submittedQuery = '';
  String? _inputError;

  // 제출할 때만 요청 (글자 칠 때마다 X), 새 검색은 page 1부터
  void _submitSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      setState(() => _inputError = '검색어를 입력해 주세요.'); // 빈 검색어는 서버에 안 보냄
      return;
    }
    setState(() {
      _inputError = null;
      _submittedQuery = query;
    });
    FocusScope.of(context).unfocus();
    context.read<PagedMoviesViewModel>().loadInitial(query: query);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('영화 검색'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _submitSearch,
                    decoration: InputDecoration(
                      labelText: '검색어',
                      border: const OutlineInputBorder(),
                      errorText: _inputError,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _submitSearch(_text.text),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<PagedMoviesViewModel>(
              builder: (context, vm, _) {
                // 처음 진입(idle)과 결과 없음(empty)을 구분
                if (vm.phase == LoadPhase.idle) {
                  return const Center(child: Text('보고 싶은 영화를 검색해 보세요.'));
                }
                if (vm.phase == LoadPhase.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.phase == LoadPhase.error) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(vm.errorMessage ?? '조회 오류입니다.'),
                        const SizedBox(height: 12),
                        MovieLogButton(
                          label: '다시 시도',
                          onPressed: () => vm.loadInitial(query: _submittedQuery),
                        ),
                      ],
                    ),
                  );
                }
                if (vm.phase == LoadPhase.empty) {
                  return Center(child: Text('"$_submittedQuery" 검색 결과가 없습니다.'));
                }

                return ListView.separated(
                  itemCount: vm.movies.length + 1,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == vm.movies.length) return MoviePageFooter(vm: vm);

                    final movie = vm.movies[index];
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
                      onTap: () => widget.onOpenMovie(movie),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}