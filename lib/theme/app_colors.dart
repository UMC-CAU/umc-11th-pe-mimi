import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 색상값을 한곳에 모아 관리합니다.
/// 화면에서 직접 Color(0xFF...)를 작성하지 말고 AppColors를 사용합니다.
abstract final class AppColors {
  static const violet = Color(0xFF6750A4);

  static const warmWhite = Color(0xFFFAF9F5);

  static const white = Color(0xFFFFFFFF);

  static const black = Color(0xFF1C1B1F);
  static const gray = Color(0xFF79747E);
}
