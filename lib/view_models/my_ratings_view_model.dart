import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'auth_view_model.dart';
import 'session_rating_store.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

// v7엔 토큰으로 내 평점 목록을 조회하는 API가 없음
// → 이번 로그인 동안 등록한 평점(SessionRatingStore)을 보여주고 수정·삭제
class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._service, this._movieService, this._store, this._auth);

  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final SessionRatingStore _store;
  final AuthViewModel _auth;
  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;
  String? refreshWarning; // 화면 코드 호환용

  Future<void> load() async {
    if (_disposed) return;
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();

    final entries = <RatingWithMovie>[];
    var missingMovies = 0;
    for (final rating in _store.ratings) {
      if (!_movieCache.containsKey(rating.movieId)) {
        try {
          _movieCache[rating.movieId] =
              await _movieService.findMovieById(rating.movieId);
        } on DioException {
          // 일시적 실패는 캐시하지 않음
        }
      }
      if (_disposed || version != _requestVersion) return;
      final movie = _movieCache[rating.movieId];
      if (movie == null) missingMovies++;
      entries.add(RatingWithMovie(rating: rating, movie: movie));
    }

    ratings = entries;
    status = entries.isEmpty ? MyRatingsLoadStatus.empty : MyRatingsLoadStatus.success;
    if (missingMovies > 0) {
      message = '일부 영화 정보를 가져오지 못해 제목·포스터를 대신 표시합니다.';
    }
    notifyListeners();
  }

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final version = _auth.sessionVersion;
    try {
      final updated = await _service.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      if (_disposed || version != _auth.sessionVersion) return;
      _store.replace(updated); // 서버가 돌려준 최신 값으로 교체
    } on DioException catch (error) {
      throw StateError(await _handleWriteError(error, ratingId));
    }
    await load();
  }

  Future<void> deleteRating(int ratingId) async {
    final version = _auth.sessionVersion;
    try {
      await _service.deleteRating(ratingId);
      if (_disposed || version != _auth.sessionVersion) return;
      _store.remove(ratingId);
    } on DioException catch (error) {
      throw StateError(await _handleWriteError(error, ratingId));
    }
    await load();
  }

  // 401 만료 → 세션 정리 / 404 → 목록에서 빼기 / 403 → 안내만
  Future<String> _handleWriteError(DioException error, int ratingId) async {
    if (isSessionExpiredError(error)) {
      await _auth.expireSession();
      return '로그인이 만료됐어요. 다시 로그인해 주세요.';
    }
    if (apiErrorCode(error) == 'RATING404_1') {
      _store.remove(ratingId);
      await load();
    }
    return ratingErrorMessage(error);
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}