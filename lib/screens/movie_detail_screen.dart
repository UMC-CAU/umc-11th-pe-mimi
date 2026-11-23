import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/favorite_detail_view_model.dart';
import '../view_models/movie_detail_view_model.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/session_rating_store.dart';
import '../view_models/sign_up_view_model.dart' show SubmitStatus;
import '../widgets/favorite_button.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId, this.initialMovie});

  final int movieId; // TMDB 영화 id
  final TmdbMovieDto? initialMovie; // 목록·검색·즐겨찾기에서 넘겨준 영화 (없을 수 있음)

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  TmdbMovieDto? _movie;
  bool _loadingMovie = false;
  bool _movieError = false;
  int? _myRating;

  @override
  void initState() {
    super.initState();
    // 넘겨받은 영화 → 홈 인기 영화 → TMDB 직접 조회 순서
    _movie = widget.initialMovie ?? _findInHome();
    if (_movie == null) _fetchMovie();

    // 화면이 처음 만들어질 때 서버의 즐겨찾기 여부를 한 번 조회 (build에서 X)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoriteDetailViewModel>().load();
    });
  }

  TmdbMovieDto? _findInHome() {
    for (final movie in context.read<MovieHomeViewModel>().popularMovies) {
      if (movie.id == widget.movieId) return movie;
    }
    return null;
  }

  Future<void> _fetchMovie() async {
    setState(() {
      _loadingMovie = true;
      _movieError = false;
    });
    try {
      final movie = await context.read<TmdbMovieService>().findMovieById(widget.movieId);
      if (!mounted) return;
      setState(() {
        _movie = movie;
        _movieError = movie == null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _movieError = true);
    } finally {
      if (mounted) setState(() => _loadingMovie = false);
    }
  }

  Future<void> _openRatingDialog(TmdbMovieDto movie) async {
    final viewModel = MovieDetailViewModel(
      context.read<RatingApiService>(),
      context.read<AuthViewModel>(),
      context.read<SessionRatingStore>(),
      movie,
    );
    int? savedScore;

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        movieTitle: movie.title,
        onSubmit: (score, comment) async {
          await viewModel.createRating(score: score, comment: comment);
          if (viewModel.submitStatus != SubmitStatus.success) {
            throw StateError(viewModel.submitMessage ?? '저장에 실패했습니다.');
          }
          savedScore = score;
        },
      ),
    );
    viewModel.dispose();

    if (!mounted || saved != true) return;
    setState(() => _myRating = savedScore);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 확인할 수 있습니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = _movie;

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: _loadingMovie
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_movieError ? '영화 정보를 불러오지 못했어요.' : '영화를 찾을 수 없습니다.'),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _fetchMovie, child: const Text('다시 시도')),
                  ],
                ),
        ),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final date = movie.releaseDate;
    final year = (date != null && date.length >= 4) ? date.substring(0, 4) : null;

    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: TmdbPosterImage(posterPath: movie.backdropPath ?? movie.posterPath),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 9주차: 제목·연도 오른쪽에 북마크 버튼
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (year != null) ...[
                            const SizedBox(height: 4),
                            Text(year, style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                          ],
                        ],
                      ),
                    ),
                    const FavoriteButton(),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: movie.voteAverage / 2, // TMDB 10점 → 별 5개
                      itemCount: 5,
                      itemSize: 24,
                      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                    ),
                    const SizedBox(width: 8),
                    Text(movie.voteAverage.toStringAsFixed(1), style: textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_myRating == null ? '아직 평점을 남기지 않았어요' : '내 평점: $_myRating점'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openRatingDialog(movie),
                    icon: const Icon(Icons.star_outline),
                    label: const Text('평점 남기기'),
                  ),
                ),
                const SizedBox(height: 24),
                Text('줄거리', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                movie.overview.isEmpty
                    ? const Center(child: Text('줄거리 정보가 없어요.'))
                    : Text(movie.overview, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}