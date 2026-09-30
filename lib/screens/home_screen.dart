import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../widgets/movie_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final featured = movies.first; // 별빛 아래 우리
    final popular = movies.skip(1).toList(); // 나머지 영화들

    return Scaffold(
      appBar: AppBar(title: const Text('MovieLog')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // 오늘의 추천
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '오늘의 추천',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _FeaturedCard(movie: featured),
          ),
          const SizedBox(height: 32),

          // 인기 영화
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '인기 영화',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: popular.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 150,
                  child: MovieCard(movie: popular[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 홈 상단의 큰 추천 카드
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/movies/${movie.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(movie.posterAsset, fit: BoxFit.cover),
              // 아래쪽을 어둡게 해서 글자가 잘 보이게
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '★ ${movie.rating} · ${movie.genre} · ${movie.year}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}