import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final TokenStorage _storage;

    // JWT를 붙일 보호 요청인지 판단
  bool _isProtected(RequestOptions options) {
    // MovieLog 서버가 아니면(TMDB 등) JWT 안 붙임
    if (options.uri.host != 'workbook.devnoco.com') return false;
    final path = options.uri.path;
    final method = options.method.toUpperCase();

    final w8Protected = path == '/v8/members/me' ||
        path == '/v8/ratings' ||
        path.startsWith('/v8/ratings/');

    // 즐겨찾기: 등록(POST)·목록(GET) / 여부 조회(GET)·해제(DELETE)
    final favorites =
        (path == '/v8/favorites' && (method == 'GET' || method == 'POST')) ||
            (RegExp(r'^/v8/favorites/[1-9]\d*$').hasMatch(path) &&
                (method == 'GET' || method == 'DELETE'));

    return w8Protected || favorites;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isProtected(options)) {
      handler.next(options);
      return;
    }
    options.headers.remove('Authorization'); // 이전 토큰 재사용 방지
    try {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (_) {
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.unknown,
        error: StateError('인증 저장소를 읽지 못했습니다.'),
      ));
    }
  }
}