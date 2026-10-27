import 'package:flutter/material.dart';

import 'movie_rating_input.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, required this.movieId, required this.title});

  final int movieId; // 나중에 자체 백엔드 평점 API의 movieId로 보낼 값
  final String title;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0; // 0 = 아직 안 고름

  @override
  Widget build(BuildContext context) {
    final hasRating = _rating > 0;

    return AlertDialog(
      title: const Text('평점 남기기'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title),
          const SizedBox(height: 16),
          MovieRatingInput(
            rating: _rating,
            onChanged: (value) {
              setState(() {
                _rating = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(hasRating ? '${_rating.toStringAsFixed(1)}점' : '별을 눌러 평점을 선택하세요'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: hasRating
              ? () {
                  debugPrint('[평점 저장] movieId: ${widget.movieId}, score: $_rating');
                  Navigator.of(context).pop(_rating);
                }
              : null,
          child: const Text('저장'),
        ),
      ],
    );
  }
}