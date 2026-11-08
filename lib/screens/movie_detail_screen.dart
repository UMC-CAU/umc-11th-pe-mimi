import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/movie_detail_view_model.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/sign_up_view_model.dart' show SubmitStatus;
import '../widgets/favorite_button.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int movieId; // TMDB 영화 id

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;
  int? _myRating;

  // 홈(인기 5개)과 영화 목록(30개)에서 TMDB id로 영화 찾기
  TmdbMovieDto? _findMovie(BuildContext context) {
    final all = [
      ...context.read<MovieHomeViewModel>().popularMovies,
      ...context.read<MovieListViewModel>().movies,
    ];
    for (final movie in all) {
      if (movie.id == widget.movieId) return movie;
    }
    return null;
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _openRatingDialog(TmdbMovieDto movie) async {
    final memberId = context.read<LearningMemberSession>().memberId;
    if (memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 회원가입을 완료해 주세요.')),
      );
      return;
    }

    final viewModel = MovieDetailViewModel(
      context.read<RatingApiService>(),
      memberId,
      movie,
    );
    int? savedScore;

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막기
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
    final movie = _findMovie(context);

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('영화를 찾을 수 없습니다.')),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final date = movie.releaseDate;
    final year = (date != null && date.length >= 4) ? date.substring(0, 4) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        actions: [
          FavoriteButton(isFavorite: _isFavorite, onPressed: _toggleFavorite),
        ],
      ),
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
                Text(
                  movie.title,
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (year != null) ...[
                  const SizedBox(height: 4),
                  Text(year, style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                ],
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
                Text(
                  _myRating == null
                      ? '아직 평점을 남기지 않았어요'
                      : '내 평점: $_myRating점',
                ),
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