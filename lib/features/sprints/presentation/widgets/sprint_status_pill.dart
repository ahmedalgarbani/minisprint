import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/pill.dart';
import '../../domain/entities/sprint.dart';

class SprintStatusPill extends StatelessWidget {
  final SprintStatus status;

  const SprintStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SprintStatus.active => AppColors.info,
      SprintStatus.completed => AppColors.success,
      SprintStatus.planned => AppColors.neutral,
    };
    return Pill(
      label: S(context).sprintStatusLabel(status.value),
      color: color,
    );
  }
}
