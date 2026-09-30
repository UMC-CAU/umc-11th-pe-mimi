import 'package:flutter/material.dart';

import 'movie_rating_input.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, required this.title});

  final String title; // 영화 제목

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 3.0;

  @override
  Widget build(BuildContext context) {
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
          Text('${_rating.toStringAsFixed(1)}점'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_rating),
          child: const Text('확인'),
        ),
      ],
    );
  }
}