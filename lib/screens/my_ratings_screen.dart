import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_dto.dart';
import '../data/models/rating_with_movie.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/movielog_button.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  Future<void> _onEditPressed(BuildContext context, RatingDto rating) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막기
      builder: (_) => RatingDialog(
        initialScore: rating.score,
        initialComment: rating.comment, // null이면 TextField는 빈 칸
        onSubmit: (score, comment) => context.read<MyRatingsViewModel>().updateRating(
              ratingId: rating.ratingId,
              score: score,
              comment: comment,
            ),
      ),
    );
    if (!context.mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('평점을 수정했습니다.')),
    );
  }

  Future<void> _onDeletePressed(BuildContext context, RatingDto rating) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 삭제 중 바깥 탭으로 닫히는 것도 막기
      builder: (_) => _DeleteRatingDialog(
        onConfirm: () => context.read<MyRatingsViewModel>().deleteRating(rating.ratingId),
      ),
    );
    if (!context.mounted || confirmed != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('평점을 삭제했습니다.')),
    );
  }

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
                    Text(vm.refreshWarning ?? vm.message ?? '평점을 불러오지 못했습니다.'),
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
                  for (final entry in vm.ratings)
                    _RatingCard(
                      entry: entry,
                      onEdit: () => _onEditPressed(context, entry.rating),
                      onDelete: () => _onDeletePressed(context, entry.rating),
                    ),
                ],
              );
          }
        },
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final RatingWithMovie entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
          Column(
            children: [
              IconButton(
                tooltip: '수정',
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: '삭제',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: AlertDialog(
        title: const Text('평점을 삭제할까요?'),
        content: const Text('삭제한 평점은 복구할 수 없습니다.'),
        actions: [
          MovieLogButton(
            label: '취소',
            onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
          ),
          MovieLogButton(
            label: '삭제',
            isLoading: _isDeleting,
            onPressed: _isDeleting ? null : _onConfirm,
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is StateError ? error.message : '삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.',
          ),
        ),
      );
    }
  }
}