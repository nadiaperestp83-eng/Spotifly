/*
 *     Copyright (C) 2026 Valeri Gokadze
 *
 *     Musify is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Musify is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Musify, including how to contribute,
 *     please visit: https://github.com/gokadzev/Musify
 */

// lib/theme/app_themes.dart
//
// Design system do fork "Musifly" — Light Mode puro, paleta vermelha,
// tipografia Inter. Mantém as MESMAS variáveis/funções globais que
// main.dart e settings_page.dart já usam (themeMode, brightness,
// transitionsBuilder, getThemeMode, getBrightnessFromThemeMode,
// getAppColorScheme, getAppTheme) — só o CONTEÚDO delas mudou.
//
// Dependência nova no pubspec.yaml:
//   dependencies:
//     google_fonts: ^6.2.1
// (rode `flutter pub get` depois de adicionar)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musify/services/settings_manager.dart';

/// ---------------------------------------------------------------------
/// Paleta de cores (baseada nas imagens de referência do design)
/// ---------------------------------------------------------------------
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF9FAFB); // cinza muito claro
  static const Color surface = Color(0xFFFFFFFF); // branco puro
  static const Color accent = Color(0xFFDC2626); // vermelho principal
  static const Color accentDark = Color(0xFFB91C1C);
  static const Color accentSoft = Color(0xFFFEE2E2);
  static const Color playButtonBlue = Color(0xFF38BDF8); // botão play circular
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnAccent = Color(0xFFFFFFFF);
  static const Color iconInactive = Color(0xFF6B7280);
  static const Color iconActive = accent;
  static const Color divider = Color(0xFFE5E7EB);
}

/// Raios de canto padrão dos cards "quase quadrados" do design.
class AppRadii {
  AppRadii._();

  static const double card = 20.0;
  static const double cardLarge = 24.0;
  static const double chip = 999.0;
  static const double sheet = 28.0;
}

/// Tipografia Inter — títulos grandes em bold, texto secundário em cinza médio.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => GoogleFonts.interTextTheme().copyWith(
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      height: 1.15,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
  );
}

// ---------------------------------------------------------------------
// Estado global de tema (MESMAS variáveis que main.dart/settings_page.dart
// já importam e escrevem em runtime — preservadas para não quebrar nada).
// ---------------------------------------------------------------------
ThemeMode themeMode = getThemeMode(themeModeSetting);
Brightness brightness = getBrightnessFromThemeMode(themeMode);

PageTransitionsBuilder transitionsBuilder = predictiveBack.value
    ? const PredictiveBackPageTransitionsBuilder()
    : const CupertinoPageTransitionsBuilder();

/// O design é Light Mode puro por definição — independente do que o
/// usuário escolher em Settings (system/dark/light), a marca sempre
/// renderiza em claro, então o app nunca fica com ícones de status bar
/// invertidos. `themeMode` continua sendo salvo normalmente pelas
/// Settings, só não afeta mais a aparência.
Brightness getBrightnessFromThemeMode(ThemeMode themeMode) => Brightness.light;

ThemeMode getThemeMode(int themeModeIndex) {
  const themeModes = ThemeMode.values;
  if (themeModeIndex >= 0 && themeModeIndex < themeModes.length) {
    return themeModes[themeModeIndex];
  }
  return ThemeMode.system;
}

/// Ignora as cores dinâmicas do Android 12+ (Material You) e qualquer
/// accent color customizado pelo usuário: o design pede uma paleta FIXA
/// (vermelho #DC2626 sobre branco / cinza muito claro), não cores extraídas
/// do papel de parede nem do seletor de cor das Settings. Assinatura
/// idêntica à original, então DynamicColorBuilder em main.dart continua
/// funcionando sem mudanças.
ColorScheme getAppColorScheme(
  ColorScheme? lightColorScheme,
  ColorScheme? darkColorScheme,
) {
  return const ColorScheme.light(
    brightness: Brightness.light,
    primary: AppColors.accent,
    onPrimary: AppColors.textOnAccent,
    primaryContainer: AppColors.accentSoft,
    onPrimaryContainer: AppColors.accentDark,
    secondary: AppColors.accent,
    onSecondary: AppColors.textOnAccent,
    secondaryContainer: AppColors.accentSoft,
    onSecondaryContainer: AppColors.accentDark,
    tertiary: AppColors.playButtonBlue,
    onTertiary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerHighest: AppColors.background,
    surfaceContainerHigh: AppColors.surface,
    surfaceContainer: AppColors.background,
    surfaceContainerLow: AppColors.background,
    surfaceContainerLowest: AppColors.surface,
    error: AppColors.accent,
    onError: AppColors.textOnAccent,
    outline: AppColors.divider,
    outlineVariant: AppColors.divider,
  );
}

ThemeData getAppTheme(ColorScheme colorScheme) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    cardColor: AppColors.surface,
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: AppTypography.textTheme,
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // ---------- AppBar ----------
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppTypography.textTheme.headlineLarge,
    ),

    // ---------- Cards ----------
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
    ),

    // ---------- Bottom Navigation Bar ----------
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.iconInactive,
      selectedLabelStyle: AppTypography.textTheme.labelLarge?.copyWith(
        color: AppColors.accent,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: AppTypography.textTheme.labelLarge,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // ---------- NavigationBar (Material 3) ----------
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      elevation: 8,
      height: 70,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return AppTypography.textTheme.labelLarge?.copyWith(
          color: selected ? AppColors.accent : AppColors.iconInactive,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.accent : AppColors.iconInactive,
        );
      }),
    ),

    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      indicatorColor: Colors.transparent,
      selectedIconTheme: const IconThemeData(color: AppColors.accent),
      unselectedIconTheme: const IconThemeData(color: AppColors.iconInactive),
      selectedLabelTextStyle: AppTypography.textTheme.labelLarge?.copyWith(
        color: AppColors.accent,
      ),
      unselectedLabelTextStyle: AppTypography.textTheme.labelLarge,
    ),

    // ---------- FAB (botão "+" vermelho da Library) ----------
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.textOnAccent,
      elevation: 2,
      shape: StadiumBorder(),
    ),

    // ---------- Botões ----------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.playButtonBlue,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 0,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.accent),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.textPrimary),
    ),

    // ---------- Listas ----------
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.accent,
      textColor: AppColors.textPrimary,
      titleTextStyle: AppTypography.textTheme.titleMedium,
      subtitleTextStyle: AppTypography.textTheme.bodyMedium,
    ),

    // ---------- Divisores ----------
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // ---------- Tabs (Library: Songs / Playlists / Albums / Artists) ----------
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.accent,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTypography.textTheme.titleMedium,
      unselectedLabelStyle: AppTypography.textTheme.bodyLarge,
      indicatorColor: AppColors.accent,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
      dividerColor: Colors.transparent,
    ),

    // ---------- Campo de busca / inputs (linha sublinhada) ----------
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      hintStyle: AppTypography.textTheme.titleMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
      suffixIconColor: AppColors.textSecondary,
      prefixIconColor: AppColors.textSecondary,
    ),

    // ---------- Ícones globais ----------
    iconTheme: const IconThemeData(color: AppColors.textPrimary),

    // ---------- Slider / progress (mini player) ----------
    sliderTheme: SliderThemeData(
      year2023: false,
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: AppColors.divider,
      thumbColor: AppColors.accent,
      overlayColor: AppColors.accent.withValues(alpha: 0.12),
      trackHeight: 3,
    ),

    // ---------- BottomSheet (menus de contexto "⋮") ----------
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
      ),
    ),

    // ---------- Dialogs ----------
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sheet),
      ),
    ),

    // ---------- Popup menu ----------
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // ---------- SnackBar ----------
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.accentSoft,
      contentTextStyle: const TextStyle(
        color: AppColors.accentDark,
        fontWeight: FontWeight.w500,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      actionTextColor: AppColors.accent,
    ),

    // ---------- Chips ----------
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.accentSoft,
      labelStyle: AppTypography.textTheme.labelLarge?.copyWith(color: AppColors.accent),
      selectedColor: AppColors.accent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      side: BorderSide.none,
    ),

    // ---------- Transições de página (mantido igual ao original) ----------
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: transitionsBuilder,
      },
    ),
  );
}
