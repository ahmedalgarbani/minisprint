import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF10B981);

  // Light neutrals
  static const Color lightBackground = Color(0xFFF4F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEBECF0);
  static const Color lightBorder = Color(0xFFDFE1E6);
  static const Color lightText = Color(0xFF172B4D);
  static const Color lightTextSecondary = Color(0xFF5E6C84);

  // Dark neutrals
  static const Color darkBackground = Color(0xFF1D2125);
  static const Color darkSurface = Color(0xFF22272B);
  static const Color darkSurfaceVariant = Color(0xFF2C333A);
  static const Color darkBorder = Color(0xFF38414A);
  static const Color darkText = Color(0xFFDEE4EA);
  static const Color darkTextSecondary = Color(0xFF9FADBC);

  // Semantic
  static const Color success = Color(0xFF22A06B);
  static const Color warning = Color(0xFFE2B203);
  static const Color error = Color(0xFFE34935);
  static const Color info = Color(0xFF1D7AFC);
  static const Color neutral = Color(0xFF8590A2);

  // Work item types
  static const Color story = Color(0xFF22A06B);
  static const Color task = Color(0xFF1D7AFC);
  static const Color bug = Color(0xFFE34935);

  // Priorities
  static const Color priorityHigh = Color(0xFFE34935);
  static const Color priorityMedium = Color(0xFFF5A623);
  static const Color priorityLow = Color(0xFF1D7AFC);

  static Color statusColor(String status) => switch (status) {
    TaskStatus.backlog => neutral,
    TaskStatus.todo => neutral,
    TaskStatus.inProgress => info,
    TaskStatus.review => const Color(0xFF8F7EE7),
    TaskStatus.done => success,
    _ => const Color(0xFF6CC3E0),
  };

  static Color priorityColor(String priority) => switch (priority) {
    TaskPriority.high => priorityHigh,
    TaskPriority.medium => priorityMedium,
    TaskPriority.low => priorityLow,
    _ => neutral,
  };
}
