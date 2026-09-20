# MovieLog 1주차 미션 — 내 프로필 화면

## 실행 전 해야 할 일 (2가지)
1. **Manrope 폰트**: MovieLog 공통 Asset & Font ZIP에서 `Manrope-VariableFont_wght.ttf`를
   내려받아 `assets/fonts/`에 넣고, `pubspec.yaml`의 `fonts:` 주석을 해제하세요.
2. **MovieLog 로고**: `assets/logos/movielog_logo.svg`는 임시 영화 카메라 아이콘입니다.
   공통 ZIP의 실제 `movielog_logo.svg`로 교체하세요.

그 다음:
```
flutter pub get
flutter run
```

## 구현 범위 (Required + Challenge Mission)
- `lib/theme/` — AppColors, AppTextStyles, AppTheme(ColorScheme/TextTheme/AppBarTheme 연결)
- `lib/widgets/common_app_bar.dart` — 공용 AppBar
- `lib/widgets/stat_item.dart`, `profile_stats.dart` — `List<ProfileStat>`를 `map`으로 위젯 생성 (Challenge)
- `lib/widgets/favorite_genres.dart` — 장르 List를 `map`으로 Chip 생성 (Challenge)
- `lib/widgets/profile_header.dart` — 프로필 이미지 없을 때 기본 Icon 표시 (Challenge)
- `lib/screens/profile_screen.dart` — SvgPicture.asset + colorFilter로 단색 로고 테마 색상 적용 (Challenge)
- 버튼(프로필 수정)은 모양만 구현, 화면 이동/입력 기능 없음

## 남은 셀프 체크
- [ ] Figma 기준 화면과 비교 캡처
- [ ] `flutter analyze` 오류 없음 확인 (이 환경엔 Flutter SDK가 없어 로컬에서 직접 확인 필요)
- [ ] GitHub `feature/week-1` 브랜치로 커밋 → PR 생성
