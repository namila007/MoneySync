import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'moneysync_theme.dart';

abstract final class AppTheme {
  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final dividerColor = isDark
        ? AppColors.darkText.withValues(alpha: 0.30)
        : AppColors.text.withValues(alpha: 0.40);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.accent500 : AppColors.accent,
      onPrimary: isDark ? AppColors.darkBg : AppColors.bg,
      primaryContainer: isDark ? AppColors.accent900 : AppColors.accent100,
      onPrimaryContainer: isDark ? AppColors.accent200 : AppColors.accent800,
      secondary: isDark ? AppColors.accent400 : AppColors.accent2,
      onSecondary: isDark ? AppColors.darkBg : AppColors.bg,
      secondaryContainer: isDark ? AppColors.accent800 : AppColors.accent200,
      onSecondaryContainer: isDark ? AppColors.accent100 : AppColors.accent900,
      surface: isDark ? AppColors.darkSurface : AppColors.surface,
      onSurface: isDark ? AppColors.darkText : AppColors.text,
      surfaceContainerHighest: isDark
          ? AppColors.darkSurface
          : AppColors.surface,
      error: isDark ? AppColors.accent500 : AppColors.accent700,
      onError: isDark ? AppColors.darkBg : AppColors.bg,
      errorContainer: isDark ? AppColors.accent900 : AppColors.accent100,
      onErrorContainer: isDark ? AppColors.accent200 : AppColors.accent800,
      outline: dividerColor,
      outlineVariant: isDark
          ? AppColors.darkText.withValues(alpha: 0.15)
          : AppColors.text.withValues(alpha: 0.20),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'Archivo',
      textTheme: AppTypography.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      dividerColor: dividerColor,
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 2,
        space: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.h5.copyWith(color: colorScheme.onSurface),
        shape: Border(bottom: BorderSide(color: dividerColor, width: 2)),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        labelStyle: AppTypography.bodyXs.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: AppTypography.label,
          minimumSize: const Size(0, 36),
          maximumSize: const Size(double.infinity, 36),
          padding: const EdgeInsets.symmetric(horizontal: 14.4, vertical: 8),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          textStyle: AppTypography.label,
          minimumSize: const Size(0, 36),
          maximumSize: const Size(double.infinity, 36),
          padding: const EdgeInsets.symmetric(horizontal: 14.4, vertical: 8),
          side: BorderSide(color: dividerColor),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: AppTypography.label,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(36, 36),
          maximumSize: const Size(36, 36),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.micro.copyWith(color: colorScheme.primary);
          }
          return AppTypography.micro.copyWith(color: AppColors.neutral600);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accent, size: 20);
          }
          return const IconThemeData(color: AppColors.neutral600, size: 20);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        titleTextStyle: AppTypography.h4.copyWith(color: colorScheme.onSurface),
        contentTextStyle: AppTypography.bodySmall.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.85),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        selectedColor: colorScheme.primary,
        disabledColor: AppColors.neutral200,
        labelStyle: AppTypography.micro,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        side: BorderSide.none,
        surfaceTintColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.bg;
          return AppColors.neutral400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return AppColors.neutral300;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(AppTypography.bodySmall),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
      ),
      extensions: [isDark ? MoneySyncTheme.dark : MoneySyncTheme.light],
    );
  }
}
