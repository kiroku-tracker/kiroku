import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const radius = 9.0;

  static const fontFamily = 'Segoe UI';

  static ThemeData dark() {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accentText,
      surface: AppColors.background,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.muted,
      surfaceContainerHighest: AppColors.poster,
      outline: AppColors.inputBorder,
      error: AppColors.dangerText,
    );

    final buttonShape = WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    );
    const buttonText = WidgetStatePropertyAll(
      TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
    const buttonSize = WidgetStatePropertyAll(Size(0, 40));
    const buttonPadding = WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 15),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.divider,
      splashFactory: NoSplash.splashFactory,
      focusColor: AppColors.focus.withValues(alpha: 0.18),
      hoverColor: Colors.white.withValues(alpha: 0.04),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          height: 1.15,
          color: AppColors.text,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        bodyLarge: TextStyle(fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, height: 1.45),
        bodySmall: TextStyle(
          fontSize: 13,
          height: 1.45,
          color: AppColors.muted,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: buttonShape,
          textStyle: buttonText,
          minimumSize: buttonSize,
          padding: buttonPadding,
          iconSize: const WidgetStatePropertyAll(17),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white,
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.accent.withValues(alpha: 0.45);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.accentHover;
            }
            return AppColors.accent;
          }),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: buttonShape,
          textStyle: buttonText,
          minimumSize: buttonSize,
          padding: buttonPadding,
          iconSize: const WidgetStatePropertyAll(17),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? AppColors.muted
                : AppColors.secondaryButtonText,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? AppColors.muted
                : AppColors.secondaryButtonText,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.secondaryButtonBorder),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? Colors.transparent
                : states.contains(WidgetState.hovered)
                ? AppColors.secondaryButtonHover
                : AppColors.secondaryButton,
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: buttonShape,
          textStyle: buttonText,
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered)
                ? Colors.white
                : AppColors.navIdle,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered)
                ? Colors.white
                : AppColors.navIdle,
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? AppColors.navIdle.withValues(alpha: 0.35)
                : states.contains(WidgetState.hovered)
                ? Colors.white
                : AppColors.navIdle,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered)
                ? const Color(0xFF292730)
                : Colors.transparent,
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.input,
        hintStyle: const TextStyle(color: AppColors.muted),
        prefixIconColor: const Color(0xFF888491),
        suffixIconColor: const Color(0xFF888491),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.focus, width: 2),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.accentText,
        selectionColor: Color(0x665B46C7),
      ),
      menuTheme: const MenuThemeData(style: menuStyle),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.accent
              : const Color(0xFF3A3842),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.inputBorder),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        barrierColor: const Color(0xAD000000),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.menu,
          border: Border.all(color: AppColors.menuBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: AppColors.menuItemText, fontSize: 12),
        waitDuration: const Duration(milliseconds: 400),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          Colors.white.withValues(alpha: 0.18),
        ),
        radius: const Radius.circular(8),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentText,
      ),
    );
  }

  static final updateButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return AppColors.update.withValues(alpha: 0.45);
      }
      return states.contains(WidgetState.hovered)
          ? AppColors.updateHover
          : AppColors.update;
    }),
  );

  static const menuStyle = MenuStyle(
    backgroundColor: WidgetStatePropertyAll(AppColors.menu),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    elevation: WidgetStatePropertyAll(12),
    shadowColor: WidgetStatePropertyAll(Color(0x85000000)),
    padding: WidgetStatePropertyAll(EdgeInsets.all(7)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: AppColors.menuBorder),
      ),
    ),
  );
}
