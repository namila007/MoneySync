import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class MoneySyncTheme extends ThemeExtension<MoneySyncTheme> {
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const MoneySyncTheme({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  static const MoneySyncTheme light = MoneySyncTheme(
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.accent700,
    info: AppColors.info,
  );

  static const MoneySyncTheme dark = MoneySyncTheme(
    success: AppColors.successDark,
    warning: AppColors.warningDark,
    error: AppColors.accent500,
    info: AppColors.infoDark,
  );

  @override
  MoneySyncTheme copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) => MoneySyncTheme(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    info: info ?? this.info,
  );

  @override
  MoneySyncTheme lerp(ThemeExtension<MoneySyncTheme>? other, double t) {
    if (other is! MoneySyncTheme) return this;
    return MoneySyncTheme(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }

  static MoneySyncTheme of(BuildContext context) =>
      Theme.of(context).extension<MoneySyncTheme>() ?? light;
}
