import 'package:flutter/foundation.dart';

import '../data/models/rating_dto.dart';

class SessionRatingStore extends ChangeNotifier {
  final List<RatingDto> _ratings = [];

  List<RatingDto> get ratings => List.unmodifiable(_ratings);

  void add(RatingDto rating) {
    _ratings.removeWhere((r) => r.ratingId == rating.ratingId);
    _ratings.insert(0, rating);
    notifyListeners();
  }

  void replace(RatingDto rating) {
    final index = _ratings.indexWhere((r) => r.ratingId == rating.ratingId);
    if (index == -1) return;
    _ratings[index] = rating;
    notifyListeners();
  }

  void remove(int ratingId) {
    _ratings.removeWhere((r) => r.ratingId == ratingId);
    notifyListeners();
  }

  void clear() {
    if (_ratings.isEmpty) return;
    _ratings.clear();
    notifyListeners();
  }
}