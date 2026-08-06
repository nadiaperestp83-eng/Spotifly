// lib/constants/secrets.dart
//
// A chave do Listen Notes NUNCA fica hardcoded aqui. Ela é lida em tempo
// de build via --dart-define, e o valor real mora num GitHub Secret
// (Settings > Secrets and variables > Actions > New repository secret,
// nome: LISTEN_NOTES_API_KEY), nunca commitado no repositório.
//
// Build local (dev):
//   flutter run --dart-define=LISTEN_NOTES_API_KEY=sua_chave_aqui
//
// Build no GitHub Actions: veja build_release_apk.yml — o step de build
// já passa `--dart-define=LISTEN_NOTES_API_KEY=${{ secrets.LISTEN_NOTES_API_KEY }}`.
//
// Se a chave não for informada (nem local nem no CI), o valor fica vazio
// e listen_notes.dart automaticamente pula a chamada e deixa o Internet
// Archive (que não precisa de chave) cobrir sozinho.

const String listenNotesApiKey = String.fromEnvironment(
  'LISTEN_NOTES_API_KEY',
);
