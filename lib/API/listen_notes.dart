// lib/API/listen_notes.dart
//
// Integracao NOVA com a API do Listen Notes (https://www.listennotes.com/api/).
// Busca episodios (type=episode) e ja filtra por duracao usando o
// parametro oficial da API len_max (em MINUTOS) - regra de ouro: nada
// acima de 10 minutos. Uma segunda checagem local (por segundo) garante
// isso mesmo se a API devolver algo fora da faixa.
//
// Requer o pacote `http` no pubspec.yaml:
//   dependencies:
//     http: ^1.2.0

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:musify/constants/secrets.dart';

const _searchUrl = 'https://listen-api.listennotes.com/api/v2/search';
const int _maxDurationSeconds = 600; // 10 minutos - regra de ouro

/// Busca episodios de storytelling/poesia no Listen Notes, no maximo
/// [pageSize] resultados, todos com <=10 minutos de duracao. Retorna uma
/// lista normalizada de mapas:
/// {id, title, author, image, audioUrl, durationSec, source: 'listennotes'}
///
/// Retorna lista vazia (sem lancar excecao) em caso de chave ausente, erro
/// de rede, timeout ou resposta inesperada - quem chama decide se aciona o
/// fallback do Internet Archive.
Future<List<Map<String, dynamic>>> fetchListenNotesEpisodes(
  String query, {
  int pageSize = 10,
}) async {
  if (listenNotesApiKey.isEmpty) {
    // Chave nao foi passada via --dart-define (nem local nem no CI).
    return [];
  }

  final uri = Uri.parse(_searchUrl).replace(
    queryParameters: {
      'q': query,
      'type': 'episode',
      'len_min': '0',
      'len_max': '10', // minutos, conforme documentacao oficial da API
      'language': 'Portuguese',
      'safe_mode': '1',
      'page_size': '$pageSize',
    },
  );

  try {
    final response = await http
        .get(uri, headers: {'X-ListenAPI-Key': listenNotesApiKey})
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) return [];

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>? ?? [];

    return results
        .map(_normalizeListenNotesEpisode)
        .whereType<Map<String, dynamic>>()
        .where((e) => (e['durationSec'] as int) <= _maxDurationSeconds)
        .toList();
  } catch (_) {
    return [];
  }
}

Map<String, dynamic>? _normalizeListenNotesEpisode(dynamic raw) {
  if (raw is! Map) return null;
  final episode = Map<String, dynamic>.from(raw);

  final podcast = episode['podcast'] is Map
      ? Map<String, dynamic>.from(episode['podcast'] as Map)
      : <String, dynamic>{};

  final title = (episode['title_original'] ?? episode['title'] ?? '')
      .toString()
      .trim();
  final audioUrl = (episode['audio'] ?? '').toString();
  if (title.isEmpty || audioUrl.isEmpty) return null;

  final durationSec = (episode['audio_length_sec'] as num?)?.toInt() ?? 0;

  final image =
      (episode['thumbnail'] ??
              episode['image'] ??
              podcast['thumbnail'] ??
              podcast['image'] ??
              '')
          .toString();

  final author =
      (podcast['title_original'] ??
              podcast['publisher_original'] ??
              episode['podcast_title_original'] ??
              '')
          .toString();

  return {
    'id': (episode['id'] ?? audioUrl).toString(),
    'title': title,
    'author': author,
    'image': image,
    'audioUrl': audioUrl,
    'durationSec': durationSec,
    'source': 'listennotes',
  };
}
