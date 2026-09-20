import 'package:flutter/material.dart';

/// 선호 장르 문자열 리스트를 받아 map으로 Chip을 생성해 Wrap으로 배치한다.
/// (Challenge Mission: 장르 데이터를 List로 만들고 map으로 Widget 생성)
class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({
    super.key,
    required this.genres,
  });

  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres
          .map(
            (genre) => Chip(
              label: Text(genre),
              backgroundColor: colors.surface,
              side: BorderSide(color: colors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
          .toList(),
    );
  }
}
