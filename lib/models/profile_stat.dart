/// 프로필 통계 항목 1개를 표현하는 데이터 모델.
/// (Challenge Mission: List<ProfileStat>을 만들고 map으로 Widget 생성)
class ProfileStat {
  const ProfileStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}
