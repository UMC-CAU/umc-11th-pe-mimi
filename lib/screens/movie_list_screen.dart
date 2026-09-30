import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../widgets/genre_chips.dart';
import '../widgets/movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const _genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러', '액션'];

  String _selectedGenre = '전체';

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedGenre == '전체'
        ? movies
        : movies.where((m) => m.genre == _selectedGenre).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('영화')),
      body: Column(
        children: [
          GenreChips(
            genres: _genres,
            selected: _selectedGenre,
            onSelected: (genre) {
              setState(() {
                _selectedGenre = genre;
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.55,
              ),
              itemBuilder: (context, index) {
                return MovieCard(movie: filtered[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}