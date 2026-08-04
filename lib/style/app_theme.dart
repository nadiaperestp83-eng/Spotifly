// lib/style/app_theme.dart
//
// Tema global do fork "Musifly" — Light Mode puro, paleta vermelha,
// tipografia Inter (substituta livre da SF Pro/Apple).
//
// ⚠️ Este arquivo NÃO toca em API, use cases, services ou navegação.
// Ele só define aparência (ThemeData). Para ativar, veja as instruções
// de integração no fim do arquivo.
//
// Dependência nova necessária no pubspec.yaml:
//   dependencies:
//     google_fonts: ^6.2.1
//
// (rode `flutter pub get` depois de adicionar)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de cores do design system (baseada nas imagens de referência).
class AppColors {
  AppColors._();

  // Fundo
  static const Color background = Color(0xFFF9FAFB); // cinza muito claro
  static const Color surface = Color(0xFFFFFFFF); // branco puro (cards, nav bar, mini player)

  // Destaque (accent)
  static const Color accent = Color(0xFFDC2626); // vermelho principal
  static const Color accentDark = Color(0xFFB91C1C); // vermelho para estados pressed/hover
  static const Color accentSoft = Color(0xFFFEE2E2); // vermelho bem clarinho (fundos sutis, badges)

  // Botão "Play" circular azul claro (telas de listagem)
  static const Color playButtonBlue = Color(0xFF38BDF8);

  // Texto
  static const Color textPrimary = Color(0xFF111827); // quase preto, títulos
  static const Color textSecondary = Color(0xFF6B7280); // cinza médio, subtítulos/artista
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Ícones inativos (bottom nav, etc.)
  static const Color iconInactive = Color(0xFF6B7280);
  static const Color iconActive = accent;

  // Linhas e divisores
  static const Color divider = Color(0xFFE5E7EB);

  // Gradientes de overlay para cards de capítulo/podcast (nightTales / soundPoetry)
  static const List<Color> overlayDark = [Colors.transparent, Color(0xE6000000)];
  static const List<Color> overlayPink = [Color(0x00E11D8F), Color(0xE6BE185D)];
}

/// Raio de canto padrão usado nos cards "quase quadrados" do design.
class AppRadii {
  AppRadii._();

  static const double card = 20.0;
  static const double cardLarge = 24.0;
  static const double chip = 999.0; // pill / totalmente arredondado
  static const double sheet = 28.0;
}

/// Tipografia Inter, com pesos consistentes com o briefing
/// (títulos grandes em bold, texto secundário em cinza médio).
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => GoogleFonts.interTextTheme().copyWith(
    // Título de tela grande, ex.: "Bom dia", "Search", "Library", "Settings"
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      height: 1.15,
    ),
    // Título de seção, ex.: "Recently Played", "recommendedForYou"
    titleLarge: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    // Título de item (nome da música em cards/listas)
    titleMedium: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    // Corpo padrão
    bodyLarge: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    // Texto secundário — artista, "Feito pra você", legendas
    bodyMedium: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
    // Rótulos pequenos (bottom nav, tabs)
    labelLarge: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
  );
}

/// Tema principal do app — ÚNICO tema (light mode puro, conforme o briefing).
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.accent,
      onPrimary: AppColors.textOnAccent,
      secondary: AppColors.accent,
      onSecondary: AppColors.textOnAccent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.accent,
      onError: AppColors.textOnAccent,
      outline: AppColors.divider,
    );

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
      // ---------- AppBar (cabeçalhos "Bom dia", "Search", "Library", "Settings") ----------
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.textTheme.headlineLarge,
      ),

      // ---------- Bottom Navigation Bar ----------
      // Ícones outline (inativo) / filled (ativo), cinza -> vermelho.
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

      // ---------- Navigation Bar (Material 3 equivalente, caso o app use NavigationBar) ----------
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

      // ---------- Botões elevados (ex.: botão "Play" azul claro nas listagens) ----------
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

      // ---------- Cards (capas de música, cards de nightTales/soundPoetry) ----------
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),

      // ---------- Listas (ListTile: itens de "Músicas mais tocadas", Settings, etc.) ----------
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.accent,
        textColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.textTheme.titleMedium,
        subtitleTextStyle: AppTypography.textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ---------- Divisores sutis ----------
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

      // ---------- Campo de busca (linha sublinhada, sem borda de caixa) ----------
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

      // ---------- Progress indicators (barra de progresso do mini player, se usar Slider) ----------
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

      // ---------- BottomSheet (usado por menus de contexto "⋮") ----------
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
        ),
      ),

      // ---------- Chips (usados em filtros/gêneros, se existirem) ----------
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
}
