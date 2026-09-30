import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/movie.dart';
import '../widgets/favorite_button.dart';
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;
  double? _myRating; // 내가 남긴 평점 (아직 없으면 null)

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

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

  Future<void> _openRatingDialog(Movie movie) async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => RatingDialog(title: movie.title),
    );

    if (result == null || !mounted) return; // 취소했으면 아무것도 안 함

    setState(() {
      _myRating = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(widget.movieId);

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('영화를 찾을 수 없습니다.')),
      );
    }

    final textTheme = Theme.of(context).textTheme;

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
            child: Image.asset(movie.posterAsset, fit: BoxFit.cover),
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
                const SizedBox(height: 4),
                Text(
                  '${movie.year} · ${movie.genre} · ${movie.runtime}분',
                  style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // 평균 평점 (보기 전용 별)
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: movie.rating,
                      itemCount: 5,
                      itemSize: 24,
                      itemBuilder: (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                    ),
                    const SizedBox(width: 8),
                    Text('${movie.rating}', style: textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),

                // 내가 남긴 평점
                Text(
                  _myRating == null
                      ? '아직 평점을 남기지 않았어요'
                      : '내 평점: ${_myRating!.toStringAsFixed(1)}점',
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

                Text(
                  '줄거리',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(movie.synopsis, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}