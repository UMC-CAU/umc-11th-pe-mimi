import 'package:dio/dio.dart';

import '../../core/network/api_error.dart';
import '../models/common_response.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';

// v7 등록·수정 응답: CommonResponse 안의 result가 Rating 객체
RatingDto parseRatingResult(Object? data) {
  if (data is! Map<String, dynamic>) {
    throw StateError('평점 응답 형식이 올바르지 않습니다.');
  }
  final common = CommonResponse<RatingDto>.fromJson(
    data,
    (value) => RatingDto.fromJson(value as Map<String, dynamic>),
  );
  final rating = common.result;
  if (rating == null) throw StateError('평점 result가 없습니다.');
  return rating;
}

// 공개 조회 응답: wrapper 없이 바로 배열
List<RatingDto> parseRatingList(Object? data) {
  if (data is! List) throw StateError('평점 목록 응답은 배열이어야 합니다.');
  return data
      .map((value) => RatingDto.fromJson(value as Map<String, dynamic>))
      .toList();
}

class RatingApiService {
  RatingApiService(this._publicDio, this._authDio);

  final Dio _publicDio; // 토큰 X
  final Dio _authDio; // 토큰 자동 첨부

  // 공개 API라 공개 Client 사용
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _publicDio.get('/v7/members/$memberId/ratings');
    return parseRatingList(response.data);
  }

  Future<RatingDto> createRating(CreateRatingRequest request) async {
    final response = await _authDio.post('/v7/ratings', data: request.toJson());
    return parseRatingResult(response.data);
  }

  // PATCH는 전체 교체라서 comment 생략하면 기존 후기가 지워짐 → 항상 둘 다 보냄
  Future<RatingDto> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final response = await _authDio.patch(
      '/v7/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
    return parseRatingResult(response.data);
  }

  // v7 삭제 성공은 204가 아니라 200 (result null)
  Future<void> deleteRating(int ratingId) async {
    final response = await _authDio.delete('/v7/ratings/$ratingId');
    if (response.statusCode != 200) {
      throw StateError('예상하지 못한 삭제 응답');
    }
  }
}

// 서버 message 그대로 꺼내기
String writeErrorMessage(DioException error) {
  final data = error.response?.data;
  final common = data is Map<String, dynamic>
      ? CommonResponse<Object?>.fromJson(data, (value) => value)
      : null;
  return common?.message ?? '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}

// 평점 에러 코드 → 안내 문구 (403·404·409는 로그아웃 X)
String ratingErrorMessage(DioException error) {
  switch (apiErrorCode(error)) {
    case 'RATING403_1':
      return '본인이 작성한 평점만 수정·삭제할 수 있어요.';
    case 'RATING404_1':
      return '이미 삭제됐거나 없는 평점이에요.';
    case 'RATING409_1':
      return '이미 평점을 남긴 영화예요. 마이페이지에서 확인해 주세요.';
    case 'COMMON400':
      return apiErrorMessage(error) ?? '입력값을 확인해 주세요.';
  }
  if (error.response == null) return '네트워크 상태를 확인하고 다시 시도해 주세요.';
  return writeErrorMessage(error);
}