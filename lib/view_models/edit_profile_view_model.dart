import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/services/member_api_service.dart';
import 'auth_view_model.dart';

enum EditProfileStatus { idle, saving, success, failure }

class EditProfileViewModel extends ChangeNotifier {
  EditProfileViewModel(this._memberApi, this._auth);

  final MemberApiService _memberApi;
  final AuthViewModel _auth;

  EditProfileStatus status = EditProfileStatus.idle;
  String? nicknameError; // 입력칸 아래 에러
  String? message; // 스낵바 에러
  bool _disposed = false;

  Future<bool> save(String raw) async {
    if (status == EditProfileStatus.saving) return false; // 중복 탭 방지

    final nickname = raw.trim();
    // 요청 전에 2~12자 검사 → 쓸데없는 통신 줄이기
    if (nickname.length < 2 || nickname.length > 12) {
      nicknameError = '닉네임은 2~12자로 입력해 주세요.';
      _notify();
      return false;
    }
    // 바뀐 게 없으면 요청 없이 완료
    if (nickname == _auth.member?.nickname) {
      status = EditProfileStatus.success;
      _notify();
      return true;
    }

    final version = _auth.sessionVersion;
    status = EditProfileStatus.saving;
    nicknameError = null;
    message = null;
    _notify();

    try {
      final updated = await _memberApi.updateNickname(nickname);
      if (_disposed ||
          version != _auth.sessionVersion ||
          _auth.status != AuthStatus.signedIn) {
        return false;
      }
      _auth.updateMember(updated); // 마이페이지에 새 닉네임 바로 반영
      status = EditProfileStatus.success;
      _notify();
      return true;
    } on DioException catch (error) {
      if (_disposed ||
          version != _auth.sessionVersion ||
          _auth.status != AuthStatus.signedIn) {
        return false;
      }
      status = EditProfileStatus.failure;
      switch (apiErrorCode(error)) {
        case 'AUTH401_2' || 'AUTH401_3' || 'AUTH401_4':
          await _auth.expireSession(); // 안내·이동은 로그인 화면과 Router가
        case 'MEMBER409_1':
          nicknameError = '이미 사용 중인 닉네임이에요.';
        case 'COMMON400':
          nicknameError = apiErrorMessage(error) ?? '닉네임 형식을 확인해 주세요.';
        case 'MEMBER404_1':
          message = '회원 정보를 찾을 수 없어요.';
        default:
          message = '네트워크 상태를 확인하고 다시 시도해 주세요.'; // 로그아웃 X
      }
    } catch (_) {
      if (_disposed || version != _auth.sessionVersion) return false;
      status = EditProfileStatus.failure;
      message = '알 수 없는 오류가 발생했어요.';
    }
    _notify();
    return false;
  }

  // 화면 닫힌 뒤 도착한 응답이 notifyListeners() 못 부르게
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}