// lib/API/internet_archive_stories.dart
//
// Fallback do Listen Notes: busca audios de storytelling/poesia no
// Internet Archive (API publica, sem chave). Mais lento porque precisa de
// uma 2a chamada por item pra pegar duracao + arquivo de audio, entao roda
// com timeout curto e em paralelo — itens que nao respondem a tempo sao
// descartados em vez de travar a Home.
//
// Requer o pacote `http` no pubspec.yaml (mesmo do listen_notes.dart):
//   dependencies:
//     http: ^1.2.0

import 'dart:convert';

import 'package:http/http.dart' as http;

const _searchUrl = 'https://archive.org/advancedsearch.php';
const _metadataUrl = 'https://archive.org/metadata';
const int _maxDurationSeconds = 600; // 10 minutos - mesma regra de ouro

/// Busca audios de storytelling/poesia no Internet Archive, ja filtrados
/// por duracao (<=10 min). Retorna lista normalizada no MESMO formato de
/// fetchListenNotesEpisodes:
/// {id, title, author, image, audioUrl, durationSec, source: 'archive'}
Future<List<Map<String, dynamic>>> fetchInternetArchiveStories(
  String query, {
  int rows = 8,
}) async {
  final searchUri = Uri.parse(_searchUrl).replace(
    queryParameters: {
      'q': '($query) AND mediatype:(audio)',
      'fl[]': 'identifier',
      'rows': '$rows',
      'output': 'json',
    },
  );

  List<dynamic> docs;
  try {
    final response = await http
        .get(searchUri)
        .timeout(const Duration(seconds: 6));
    if (response.statusCode != 200) return [];
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final responseBlock = decoded['response'] as Map<String, dynamic>?;
    docs = responseBlock?['docs'] as List<dynamic>? ?? [];
  } catch (_) {
    return [];
  }

  final identifiers = docs
      .map((d) => (d as Map)['identifier']?.toString())
      .whereType<String>()
      .toList();

  if (identifiers.isEmpty) return [];

  // Timeout individual por item: se o Internet Archive estiver lento,
  // aquele item específico é descartado (retorna null), sem travar os
  // outros nem a tela.
  final results = await Future.wait(
    identifiers.map(
      (id) => _fetchItemMetadata(
        id,
      ).timeout(const Duration(seconds: 5), onTimeout: () => null),
    ),
  );

  return results
      .whereType<Map<String, dynamic>>()
      .where((e) => (e['durationSec'] as int) <= _maxDurationSeconds)
      .toList();
}

Future<Map<String, dynamic>?> _fetchItemMetadata(String identifier) async {
  try {
    final response = await http.get(Uri.parse('$_metadataUrl/$identifier'));
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final metadata = Map<String, dynamic>.from(
      decoded['metadata'] as Map? ?? {},
    );
    final files = (decoded['files'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .toList();

    final audioFile = files.firstWhere(
      (f) => (f['format'] ?? '').toString().toLowerCase().contains('mp3'),
      orElse: () => const {},
    );
    if (audioFile.isEmpty) return null;

    final lengthRaw = (audioFile['length'] ?? metadata['runtime'] ?? '0')
        .toString();
    final durationSec = _parseDurationToSeconds(lengthRaw);

    final rawTitle = metadata['title'];
    final title = (rawTitle is List ? rawTitle.first : rawTitle ?? identifier)
        .toString();

    final rawCreator = metadata['creator'];
    final author = rawCreator is List
        ? rawCreator.join(', ')
        : (rawCreator ?? '').toString();

    return {
      'id': identifier,
      'title': title,
      'author': author,
      'image': 'https://archive.org/services/img/$identifier',
      'audioUrl':
          'https://archive.org/download/$identifier/${audioFile['name']}',
      'durationSec': durationSec,
      'source': 'archive',
    };
  } catch (_) {
    return null;
  }
}

/// O campo "length" do Internet Archive vem às vezes em segundos (ex: "245.3")
/// e às vezes em "mm:ss" ou "hh:mm:ss" — trata os dois formatos.
int _parseDurationToSeconds(String raw) {
  if (raw.contains(':')) {
    final parts = raw.split(':').map((p) => double.tryParse(p) ?? 0).toList();
    if (parts.length == 2) return (parts[0] * 60 + parts[1]).round();
    if (parts.length == 3) {
      return (parts[0] * 3600 + parts[1] * 60 + parts[2]).round();
    }
    return 0;
  }
  return double.tryParse(raw)?.round() ?? 0;
}
