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

// lib/screens/home_page.dart
// Se o caminho real do arquivo no seu fork for diferente de
// lib/screens/home_page.dart, apenas salve neste mesmo caminho existente.

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musify/constants/app_constants.dart';
import 'package:musify/extensions/l10n.dart';
import 'package:musify/main.dart';
import 'package:musify/services/common_services.dart';
import 'package:musify/services/data_manager.dart';
import 'package:musify/services/listening_stats_service.dart';
import 'package:musify/services/playlists_manager.dart';
import 'package:musify/services/settings_manager.dart';
import 'package:musify/theme/app_themes.dart';
import 'package:musify/utilities/app_utils.dart';
import 'package:musify/utilities/listening_stats_utils.dart';
import 'package:musify/widgets/announcement_box.dart';
import 'package:musify/widgets/listening_recap_card.dart';
import 'package:musify/widgets/mini_player_bottom_space.dart';
import 'package:musify/widgets/playlist_cube.dart';
import 'package:musify/widgets/song_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List> _suggestedPlaylistsFuture;
  late Future<List> _recommendedSongsFuture;

  // ---------- Seção "Ritmos do Mundo" ----------
  // Lista EXATA passada pelo usuário — nada além disso.
  static const List<String> _worldGenres = [
    'Árabe',
    'Flamenco',
    'Cigana',
    'Francesa',
    'Italiana',
    'Polca Paraguaia',
    'Fado',
  ];
  late final Future<List<Map<String, dynamic>>> _worldRhythmsFuture;
  final Set<String> _loadingGenres = {};

  @override
  void initState() {
    super.initState();
    _suggestedPlaylistsFuture = getPlaylists(
      playlistsNum: recommendedCubesNumber,
    );
    _recommendedSongsFuture = getRecommendedSongs();
    _worldRhythmsFuture = _loadWorldRhythms();
    externalRecommendations.addListener(_refreshRecommendedSongs);
  }

  // Busca MÚSICAS de verdade por gênero (não playlists — buscar playlist
  // pelo nome cru do gênero foi o que puxou "Fale Árabe", uma playlist de
  // aula de idioma, em vez de música árabe). fetchSongsList é a mesma
  // função de busca de músicas usada na Search page; "música" no final da
  // query ajuda a evitar conteúdo falado/podcast/aula.
  Future<List<Map<String, dynamic>>> _loadWorldRhythms() async {
    final results = await Future.wait(
      _worldGenres.map((genre) => fetchSongsList('$genre música')),
    );
    return List.generate(_worldGenres.length, (i) {
      return {'genre': _worldGenres[i], 'songs': List<dynamic>.from(results[i])};
    });
  }

  Future<void> _playGenreSongs(String genre, List<dynamic> songs) async {
    if (_loadingGenres.contains(genre) || songs.isEmpty) return;
    setState(() => _loadingGenres.add(genre));
    try {
      await audioHandler.playPlaylistSong(
        playlist: {'title': 'Ritmos do Mundo · $genre', 'list': songs},
        songIndex: 0,
      );
    } finally {
      if (mounted) setState(() => _loadingGenres.remove(genre));
    }
  }

  @override
  void dispose() {
    externalRecommendations.removeListener(_refreshRecommendedSongs);
    super.dispose();
  }

  void _refreshRecommendedSongs() {
    if (!mounted) return;
    setState(() {
      _recommendedSongsFuture = getRecommendedSongs();
    });
  }

  // Texto fixo em português (o design pede literalmente "Bom dia").
  // Se quiser traduzir para os outros idiomas do app depois, adicione as
  // chaves goodMorning/goodAfternoon/goodEvening no seu app_localizations
  // e troque os literais abaixo por context.l10n!.goodMorning etc.
  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final playlistHeight = MediaQuery.sizeOf(context).height * 0.25 / 1.1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: commonSingleChildScrollViewPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Cabeçalho "Bom dia" (sem AppBar) ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 20),
                child: Text(
                  _greeting(context),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),

              ValueListenableBuilder<String?>(
                valueListenable: announcementURL,
                builder: (_, _url, __) {
                  if (_url == null) return const SizedBox.shrink();
                  final isSponsorshipAnnouncement = isSponsorshipAnnouncementUrl(
                    _url,
                  );
                  final _message = isSponsorshipAnnouncement
                      ? context.l10n!.sponsorProject
                      : context.l10n!.newAnnouncement;
                  final _icon = isSponsorshipAnnouncement
                      ? FluentIcons.heart_24_filled
                      : FluentIcons.megaphone_24_filled;

                  return AnnouncementBox(
                    message: _message,
                    url: _url,
                    icon: _icon,
                    onDismiss: () async {
                      announcementURL.value = null;
                    },
                  );
                },
              ),
              _buildSuggestedPlaylists(context, playlistHeight),
              _buildSuggestedPlaylists(
                context,
                playlistHeight,
                showOnlyLiked: true,
              ),
              _buildCurrentMonthRecapSection(context),
              _buildRecommendedSongsSection(context),
              _buildWorldRhythmsSection(context),
              const MiniPlayerBottomSpace(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Título de seção em negrito, no padrão do design (ex.: "Recently Played")
  // ---------------------------------------------------------------------
  Widget _sectionTitle(BuildContext context, String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (action != null) action,
        ],
      ),
    );
  }

  // Linha de placeholders com shimmer — usada no lugar do loading padrão
  // (que estava aparecendo como um spinner grande e quebrado na Home).
  Widget _skeletonRow(double itemWidth, double itemHeight, {int count = 4}) {
    return SizedBox(
      height: itemHeight + 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => _ShimmerBox(
          width: itemWidth,
          height: itemHeight,
          borderRadius: AppRadii.cardLarge,
        ),
      ),
    );
  }

  Widget _buildSuggestedPlaylists(
    BuildContext context,
    double playlistHeight, {
    bool showOnlyLiked = false,
  }) {
    if (showOnlyLiked) {
      return ValueListenableBuilder<List<Map>>(
        valueListenable: userLikedPlaylists,
        builder: (_, likedPlaylists, __) => _buildSuggestedPlaylistsSection(
          context,
          playlistHeight,
          likedPlaylists
              .where((playlist) => !isArtistPlaylist(playlist))
              .take(recommendedCubesNumber)
              .toList(),
          showOnlyLiked: true,
        ),
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: _suggestedPlaylistsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(context, context.l10n!.suggestedPlaylists),
              _skeletonRow(playlistHeight * 0.78, playlistHeight * 0.78),
            ],
          );
        }
        return _buildSuggestedPlaylistsSection(
          context,
          playlistHeight,
          snapshot.data ?? [],
        );
      },
    );
  }

  Widget _buildSuggestedPlaylistsSection(
    BuildContext context,
    double playlistHeight,
    List<dynamic> playlists, {
    bool showOnlyLiked = false,
  }) {
    if (playlists.isEmpty) return const SizedBox.shrink();

    final sectionTitle = showOnlyLiked
        ? context.l10n!.backToFavorites
        : context.l10n!.suggestedPlaylists;
    final itemsNumber = playlists.length.clamp(0, recommendedCubesNumber);
    // Cards "quase quadrados" com cantos bem arredondados, capa preenchendo
    // o card inteiro e título/artista abaixo — igual ao mock "Recently Played".
    final cardSize = playlistHeight * 0.78;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, sectionTitle),
        SizedBox(
          height: cardSize + 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: itemsNumber,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return GestureDetector(
                onTap: () =>
                    context.push('/home/playlist/${playlist['ytid']}'),
                child: SizedBox(
                  width: cardSize,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.cardLarge),
                        child: SizedBox(
                          width: cardSize,
                          height: cardSize,
                          child: PlaylistCube(playlist, size: cardSize),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (playlist['title'] ?? '').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        (playlist['source'] ?? playlist['artist'] ?? '')
                            .toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSongsSection(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _recommendedSongsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(context, context.l10n!.recommendedForYou),
              _skeletonRow(150 * 0.72, 150),
            ],
          );
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) return const SizedBox.shrink();
        return _buildRecommendedForYouSection(context, data);
      },
    );
  }

  Widget _buildCurrentMonthRecapSection(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: wrappedEnabled,
      builder: (_, isEnabled, __) {
        if (!isEnabled) return const SizedBox.shrink();

        final currentMonthKey = listeningStatsMonthKey(DateTime.now());
        final monthStats = listeningStatsService.monthStats(currentMonthKey);
        final songs = listeningStatsService.monthTopSongs(currentMonthKey);
        final displayMinutes = monthDisplayMinutes(monthStats);
        if (displayMinutes <= 0 && songs.isEmpty) {
          return const SizedBox.shrink();
        }

        final previewSongs = songs.take(wrappedShareSongsLimit).toList();
        final periodLabel = formatMonthPeriodLabel(
          Localizations.localeOf(context),
          currentMonthKey,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, context.l10n!.timeMachine),
            ListeningRecapCard(
              periodLabel: periodLabel,
              minutes: displayMinutes,
              songs: previewSongs,
              onSongTap: (index) => _playRecapSongs(previewSongs, index),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () => context.push('/home/timeMachine'),
                  icon: const Icon(FluentIcons.arrow_right_24_regular),
                  label: Text(context.l10n!.listeningStats),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _playRecapSongs(
    List<Map<String, dynamic>> songs,
    int index,
  ) async {
    if (songs.isEmpty) return;
    await audioHandler.playPlaylistSong(
      playlist: {'title': context.l10n!.timeMachine, 'list': songs},
      songIndex: index,
    );
  }

  // ---------------------------------------------------------------------
  // recommendedForYou — reskin em cards (1º card sólido vermelho + capas
  // com título sobreposto), mantendo a MESMA fonte de dados (data) e a
  // MESMA lógica de reprodução (audioHandler.playPlaylistSong).
  // ---------------------------------------------------------------------
  Widget _buildRecommendedForYouSection(
    BuildContext context,
    List<dynamic> data,
  ) {
    final recommendedTitle = context.l10n!.recommendedForYou;
    const cardSize = 150.0;

    Future<void> playFrom(int index) => audioHandler.playPlaylistSong(
      playlist: {'title': recommendedTitle, 'list': data},
      songIndex: index,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, recommendedTitle),
        SizedBox(
          height: cardSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: data.length + 1, // +1 = card vermelho de destaque
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              // Primeiro card: fundo vermelho sólido, "recommendedForYou".
              if (index == 0) {
                return GestureDetector(
                  onTap: () => playFrom(0),
                  child: Container(
                    width: cardSize * 0.72,
                    height: cardSize,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadii.cardLarge),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          recommendedTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.textOnAccent),
                        ),
                        Text(
                          // Texto fixo (mesma observação de _greeting acima).
                          'Feito pra você',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textOnAccent.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final song = data[index - 1];
              final borderRadius = getItemBorderRadius(index - 1, data.length);
              return RepaintBoundary(
                key: listItemKey('home_recommended', index - 1, song),
                child: GestureDetector(
                  onTap: () => playFrom(index - 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.cardLarge),
                    child: SizedBox(
                      width: cardSize * 0.72,
                      height: cardSize,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Capa da música (SongBar entrega a mesma imagem
                          // usada nas listas; aqui só reaproveitamos o mesmo
                          // widget para não duplicar a lógica de carregamento
                          // de artwork).
                          SongBar(
                            song,
                            false,
                            borderRadius: borderRadius,
                          ),
                          // Gradiente + título sobreposto, alinhado embaixo.
                          IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: Text(
                              (song['title'] ?? '').toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Ritmos do Mundo — cards decorativos (gradiente + ícone, SEM depender
  // de capa de playlist — foi buscar capa pelo gênero que trouxe a
  // playlist errada). Tocar num card já TOCA músicas de verdade
  // (fetchSongsList), sem navegar pra playlist nenhuma.
  // ---------------------------------------------------------------------
  static const List<List<Color>> _genreGradients = [
    [Color(0xFFDC2626), Color(0xFF7F1D1D)],
    [Color(0xFF1F2937), Color(0xFF111827)],
    [Color(0xFFB91C1C), Color(0xFF450A0A)],
    [Color(0xFF374151), Color(0xFF111827)],
  ];

  Widget _buildWorldRhythmsSection(BuildContext context) {
    const cardSize = 150.0;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _worldRhythmsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(context, 'Ritmos do Mundo'),
              _skeletonRow(cardSize * 0.72, cardSize),
            ],
          );
        }

        final entries = snapshot.data ?? [];
        if (entries.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Ritmos do Mundo'),
            SizedBox(
              height: cardSize,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final genre = entry['genre'] as String;
                  final songs = entry['songs'] as List<dynamic>;
                  final gradient =
                      _genreGradients[index % _genreGradients.length];
                  final isLoading = _loadingGenres.contains(genre);

                  return GestureDetector(
                    onTap: songs.isEmpty
                        ? null
                        : () => _playGenreSongs(genre, songs),
                    child: Container(
                      width: cardSize * 0.72,
                      height: cardSize,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppRadii.cardLarge,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    FluentIcons.music_note_2_24_filled,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                          ),
                          Text(
                            genre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Placeholder com efeito shimmer (sem depender de pacote externo) —
/// substitui o spinner grande/quebrado do loading anterior.
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = AppRadii.card,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1 + 3 * t, 0),
                  end: Alignment(3 * t, 0),
                  colors: const [
                    AppColors.divider,
                    Color(0xFFF3F4F6),
                    AppColors.divider,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
