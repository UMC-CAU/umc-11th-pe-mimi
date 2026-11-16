import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import 'auth_view_model.dart';
import 'session_rating_store.dart';
import 'sign_up_view_model.dart' show SubmitStatus;

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(this._ratingService, this._auth, this._store, this.movie);

  final RatingApiService _ratingService;
  final AuthViewModel _auth;
  final SessionRatingStore _store;
  final TmdbMovieDto movie;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  Future<void> createRating({required int score, String? comment}) async {
    if (submitStatus == SubmitStatus.submitting) return;
    final version = _auth.sessionVersion; // 요청 중 로그아웃되면 응답 무시용
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    _notify();

    try {
      final rating = await _ratingService.createRating(
        CreateRatingRequest(movieId: movie.id, score: score, comment: comment),
      );
      if (_disposed || version != _auth.sessionVersion) return;
      _store.add(rating); // 내 평점 화면에서 수정·삭제할 수 있게 보관
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed || version != _auth.sessionVersion) return;
      submitStatus = SubmitStatus.error;
      if (isSessionExpiredError(error)) {
        submitMessage = '로그인이 만료됐어요. 다시 로그인해 주세요.';
        await _auth.expireSession(); // Router가 로그인 화면으로 보냄
      } else {
        submitMessage = ratingErrorMessage(error);
      }
    } catch (_) {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      submitMessage = '알 수 없는 오류가 발생했어요.';
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}