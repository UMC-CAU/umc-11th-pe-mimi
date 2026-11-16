import 'package:flutter/foundation.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import 'view_state.dart';

class MovieHomeViewModel extends ChangeNotifier {
  MovieHomeViewModel(this._service);

  final TmdbMovieService _service;

  ViewState _state = ViewState.loading;
  List<TmdbMovieDto> _popularMovies = [];
  String? _errorMessage;

  ViewState get state => _state;
  List<TmdbMovieDto> get popularMovies => _popularMovies;
  String? get errorMessage => _errorMessage;

  Future<void> loadPopular() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final page = await _service.fetchPopular();
      _popularMovies = page.results.take(5).toList();
      _state = _popularMovies.isEmpty ? ViewState.empty : ViewState.success;
    } catch (e) {
      _errorMessage = '인기 영화를 불러오지 못했어요.';
      _state = ViewState.error;
    }

    debugPrint('[HomeViewModel] 상태: $_state, 개수: ${_popularMovies.length}');
    notifyListeners();
  }
}