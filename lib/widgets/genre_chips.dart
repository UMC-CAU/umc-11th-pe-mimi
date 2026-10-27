import 'package:flutter/material.dart';

import '../data/models/tmdb_genre_dto.dart';

class GenreChips extends StatelessWidget {
  const GenreChips({
    super.key,
    required this.genres,
    required this.selectedId,
    required this.enabled,
    required this.onSelected,
  });

  final List<TmdbGenreDto> genres;
  final int? selectedId; // null = 전체
  final bool enabled;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length + 1, // 맨 앞 "전체"
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genreId = index == 0 ? null : genres[index - 1].id;
          final label = index == 0 ? '전체' : genres[index - 1].name;
          return ChoiceChip(
            label: Text(label),
            selected: genreId == selectedId,
            onSelected: enabled ? (_) => onSelected(genreId) : null,
          );
        },
      ),
    );
  }
}