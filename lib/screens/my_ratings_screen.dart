import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_with_movie.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/tmdb_poster_image.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 등록한 평점'),
        centerTitle: true,
      ),
      body: Consumer<MyRatingsViewModel>(
        builder: (context, vm, child) {
          switch (vm.status) {
            case MyRatingsLoadStatus.idle:
            case MyRatingsLoadStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case MyRatingsLoadStatus.empty:
              return const Center(child: Text('아직 등록한 평점이 없어요.'));
            case MyRatingsLoadStatus.error:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vm.message ?? '평점을 불러오지 못했습니다.'),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: vm.load, child: const Text('다시 시도')),
                  ],
                ),
              );
            case MyRatingsLoadStatus.success:
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (vm.message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(vm.message!, style: TextStyle(color: Colors.grey[600])),
                    ),
                  for (final entry in vm.ratings) _RatingCard(entry: entry),
                ],
              );
          }
        },
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.entry});

  final RatingWithMovie entry;

  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final movie = entry.movie;
    final textTheme = Theme.of(context).textTheme;
    final date = rating.createdAt.toLocal();
    final dateText =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TmdbPosterImage(posterPath: movie?.posterPath, width: 72, height: 108),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie?.title ?? '영화 정보 없음 (ID ${rating.movieId})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    for (var i = 1; i <= 5; i++)
                      Icon(
                        i <= rating.score ? Icons.star : Icons.star_border,
                        size: 18,
                        color: Colors.amber,
                      ),
                    const SizedBox(width: 6),
                    Text('${rating.score}점'),
                  ],
                ),
                if (rating.comment != null) ...[
                  const SizedBox(height: 6),
                  Text(rating.comment!, style: textTheme.bodyMedium),
                ],
                const SizedBox(height: 6),
                Text(dateText, style: textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}