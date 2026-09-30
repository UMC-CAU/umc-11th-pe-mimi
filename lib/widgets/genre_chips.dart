import 'package:flutter/material.dart';

class GenreChips extends StatelessWidget {
  const GenreChips({
    super.key,
    required this.genres,
    required this.selected,
    required this.onSelected,
  });

  final List<String> genres;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genres[index];
          return ChoiceChip(
            label: Text(genre),
            selected: genre == selected,
            onSelected: (_) => onSelected(genre),
          );
        },
      ),
    );
  }
}