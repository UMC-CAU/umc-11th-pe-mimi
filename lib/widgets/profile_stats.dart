import 'package:flutter/material.dart';

import '../models/profile_stat.dart';
import 'stat_item.dart';

/// ProfileStat 리스트를 받아 map으로 StatItem을 생성해 가로로 배치한다.
/// (Challenge Mission: List<ProfileStat>을 map으로 Widget 생성)
class ProfileStats extends StatelessWidget {
  const ProfileStats({
    super.key,
    required this.stats,
  });

  final List<ProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 12,
      children: stats
          .map((stat) => StatItem(label: stat.label, value: stat.value))
          .toList(),
    );
  }
}
