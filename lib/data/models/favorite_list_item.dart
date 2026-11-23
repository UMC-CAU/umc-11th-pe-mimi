import 'favorite_response_dto.dart';
import 'tmdb_movie_dto.dart';

class FavoriteListItem {
  const FavoriteListItem({
    required this.favorite,
    this.movie,
    this.errorMessage,
  });

  final FavoriteResponseDto favorite;
  final TmdbMovieDto? movie; // TMDB 조회 실패하면 null
  final String? errorMessage;

  bool get hasMovie => movie != null;
}