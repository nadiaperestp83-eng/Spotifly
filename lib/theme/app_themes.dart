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
// tipografia Inter. Mantém as MESMAS assinaturas que main.dart já importa
// (getAppColorScheme, getAppTheme, getBrightnessFromThemeMode), então NENHUMA
// outra linha do main.dart, dos services ou da navegação precisa mudar.
//
// Dependência nova no pubspec.yaml:
//   dependencies:
//     google_fonts: ^6.2.1
// (rode `flutter pub get` depois de adicionar)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

/// O app é Light Mode puro por definição de design — independente do que o
/// usuário escolher em Settings (system/dark/light), a marca sempre renderiza
/// em claro. Mantida como função para não quebrar a chamada existente em
/// `Musify.changeSettings` (main.dart).
Brightness getBrightnessFromThemeMode(ThemeMode mode) => Brightness.light;

/// Ignora as cores dinâmicas do Android 12+ (Material You) e qualquer
/// accent color customizado pelo usuário: o design pede uma paleta FIXA
/// (vermelho #DC2626 sobre branco / cinza muito claro), não cores extraídas
/// do papel de parede. Assinatura idêntica à esperada pelo DynamicColorBuilder
/// em main.dart, então a integração continua igual.
ColorScheme getAppColorScheme(
  ColorScheme? lightDynamic,
  ColorScheme? darkDynamic,
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
    surfaceContainerHighest: AppColors.background,
    surfaceContainer: AppColors.background,
    surfaceContainerLow: AppColors.background,
    surfaceContainerHigh: AppColors.surface,
    error: AppColors.accent,
    onError: AppColors.textOnAccent,
    outline: AppColors.divider,
    outlineVariant: AppColors.divider,
  );
}

/// Monta o ThemeData final a partir do ColorScheme fixo acima.
/// Mesma assinatura chamada duas vezes em main.dart (theme e darkTheme),
/// então o app nunca muda de aparência — Light Mode puro sempre.
ThemeData getAppTheme(ColorScheme colorScheme) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: AppTypography.textTheme,
    splashFactory: InkRipple.splashFactory,
  );

  return base.copyWith(
    // ---------- AppBar ----------
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppTypography.textTheme.headlineLarge,
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
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    // ---------- NavigationBar (Material 3) ----------
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      elevation: 8,
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
        padding: const EdgeInsets.all(14),
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

    // ---------- Cards ----------
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
    ),

    // ---------- Listas (Settings, listagens de música, etc.) ----------
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.accent,
      textColor: AppColors.textPrimary,
      titleTextStyle: AppTypography.textTheme.titleMedium,
      subtitleTextStyle: AppTypography.textTheme.bodyMedium,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

    // ---------- Campo de busca ----------
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
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
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: AppColors.divider,
      thumbColor: AppColors.accent,
      overlayColor: AppColors.accent.withValues(alpha: 0.12),
      trackHeight: 2,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
      linearTrackColor: AppColors.divider,
    ),

    // ---------- BottomSheet (menus de contexto "⋮") ----------
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
      ),
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
  );
}
