import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../core/session/session_guard.dart';
import '../core/utils/safe_notify.dart';
import '../data/services/favorite_api_service.dart';

class FavoriteDetailViewModel extends ChangeNotifier with SafeNotify {
  FavoriteDetailViewModel({
    required this.movieId,
    required this.favoriteApi,
    required this.sessionGuard,
    required this.accountId,
    this.onSessionExpired,
  });

  // TMDB 영화 ID. 즐겨찾기 경로엔 favoriteId가 아니라 이 값을 씀
  final int movieId;
  final FavoriteApiService favoriteApi;
  final SessionGuard sessionGuard;
  final String accountId;
  final Future<void> Function()? onSessionExpired; // 401 만료 시 8주차 세션 정리

  bool isFavorite = false;
  bool hasLoadedStatus = false;
  bool isLoading = false; // 첫 여부 조회 중
  bool isSaving = false; // 등록·해제 중
  String? errorMessage;

  // record: 세션 번호와 "지금 유효한지"를 한 번에 반환
  ({int generation, bool ok}) _snapshot() {
    final generation = sessionGuard.generation;
    return (
      generation: generation,
      ok: sessionGuard.isCurrent(generation, accountId) && !isDisposed,
    );
  }

  bool _isStale(int generation) =>
      !sessionGuard.isCurrent(generation, accountId) || isDisposed;

  Future<void> load() async {
    if (isLoading || isSaving) return;
    final snap = _snapshot();
    if (!snap.ok) return;
    isLoading = true;
    errorMessage = null;
    notifyIfAlive();
    try {
      final result = await favoriteApi.checkFavorite(movieId: movieId);
      if (_isStale(snap.generation)) return;
      isFavorite = result.isFavorite;
      hasLoadedStatus = true;
    } on DioException catch (error) {
      if (_isStale(snap.generation)) return;
      if (isSessionExpiredError(error)) {
        await onSessionExpired?.call();
        return;
      }
      errorMessage = '즐겨찾기 여부를 확인하지 못했습니다.';
    } catch (_) {
      if (_isStale(snap.generation)) return;
      errorMessage = '즐겨찾기 여부를 확인하지 못했습니다.';
    } finally {
      if (!_isStale(snap.generation)) {
        isLoading = false;
        notifyIfAlive();
      }
    }
  }

  // 서버 성공을 확인한 뒤에 북마크를 바꿈 (먼저 바꾸는 optimistic X)
  Future<void> toggle() async {
    if (isSaving || isLoading || !hasLoadedStatus) return;
    final snap = _snapshot();
    if (!snap.ok) return;
    final before = isFavorite;
    isSaving = true;
    errorMessage = null;
    notifyIfAlive();

    try {
      if (before) {
        await favoriteApi.deleteFavorite(movieId: movieId);
      } else {
        await favoriteApi.addFavorite(movieId: movieId);
      }
      if (_isStale(snap.generation)) return;
      isFavorite = !before;
    } on DioException catch (error) {
      if (_isStale(snap.generation)) return;
      final code = apiErrorCode(error);
      if (isSessionExpiredError(error)) {
        errorMessage = '로그인이 만료됐어요. 다시 로그인해 주세요.';
        await onSessionExpired?.call();
        return;
      }
      // 이미 등록(409)·이미 해제(404)면 서버의 현재 여부로 맞춤
      if (code == 'FAVORITE409_1' || code == 'FAVORITE404_1') {
        try {
          final synced = await favoriteApi.checkFavorite(movieId: movieId);
          if (_isStale(snap.generation)) return;
          isFavorite = synced.isFavorite;
        } catch (_) {
          if (_isStale(snap.generation)) return;
          isFavorite = before;
          errorMessage = '서버 상태를 다시 확인하지 못했습니다.';
        }
      } else {
        isFavorite = before; // 실패하면 이전 상태 유지
        errorMessage = before ? '즐겨찾기 해제에 실패했습니다.' : '즐겨찾기 등록에 실패했습니다.';
      }
    } catch (_) {
      if (_isStale(snap.generation)) return;
      isFavorite = before;
      errorMessage = before ? '즐겨찾기 해제에 실패했습니다.' : '즐겨찾기 등록에 실패했습니다.';
    } finally {
      if (!_isStale(snap.generation)) {
        isSaving = false;
        notifyIfAlive();
      }
    }
  }
}