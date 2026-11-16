import 'package:flutter/foundation.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import 'view_state.dart';

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service);

  final TmdbMovieService _service;
  static const _maxCount = 30;

  ViewState _state = ViewState.loading;
  List<TmdbMovieDto> _movies = [];
  List<TmdbGenreDto> _genres = [];
  int? _selectedGenreId; // null = 전체
  String? _errorMessage;
  int _requestVersion = 0;

  ViewState get state => _state;
  List<TmdbMovieDto> get movies => _movies;
  List<TmdbGenreDto> get genres => _genres;
  int? get selectedGenreId => _selectedGenreId;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;

  Future<void> init() async {
    await Future.wait([_loadGenres(), loadMovies()]);
  }

  Future<void> _loadGenres() async {
    try {
      _genres = await _service.fetchGenres();
    } catch (_) {
      _genres = [];
    }
    notifyListeners();
  }

  Future<void> selectGenre(int? genreId) async {
    if (isLoading || genreId == _selectedGenreId) return; // 로딩 중엔 변경 불가
    _selectedGenreId = genreId;
    await loadMovies();
  }

  Future<void> loadMovies() async {
    final version = ++_requestVersion;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final byId = <int, TmdbMovieDto>{};
      var pageNumber = 1;
      var hasNextPage = true;

      while (byId.length < _maxCount && hasNextPage) {
        final page = await _service.discoverMovies(
          page: pageNumber,
          genreId: _selectedGenreId,
        );
        for (final movie in page.results) {
          byId[movie.id] = movie;
          if (byId.length == _maxCount) break;
        }
        hasNextPage = pageNumber < page.totalPages && page.results.isNotEmpty;
        pageNumber++;
      }

      if (version != _requestVersion) return; // 늦게 온 옛날 응답은 무시
      _movies = byId.values.toList();
      _state = _movies.isEmpty ? ViewState.empty : ViewState.success;
    } catch (_) {
      if (version != _requestVersion) return;
      _errorMessage = '영화 목록을 불러오지 못했어요.';
      _state = ViewState.error;
    }

    debugPrint('[MovieListViewModel] 장르: $_selectedGenreId, 상태: $_state, 개수: ${_movies.length}');
    notifyListeners();
  }
}