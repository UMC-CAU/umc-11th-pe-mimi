import 'rating_dto.dart';
import 'tmdb_movie_dto.dart';

class RatingWithMovie {
  const RatingWithMovie({required this.rating, this.movie});

  final RatingDto rating;
  final TmdbMovieDto? movie; // TMDB에서 못 찾으면 null
}