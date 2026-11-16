import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

BaseOptions _movieLogOptions() => BaseOptions(
      baseUrl: 'https://workbook.devnoco.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

// 공개 요청용: 로그인, 회원가입, 중복 확인, 유저별 평점 조회 (토큰 없음)
Dio createMovieLogClient() => Dio(_movieLogOptions());

// 보호 요청용: 내 정보, 평점 등록/수정/삭제 (토큰 자동 첨부)
Dio createAuthMovieLogClient(TokenStorage storage) {
  final dio = Dio(_movieLogOptions());
  dio.interceptors.add(AuthInterceptor(storage));
  return dio;
}