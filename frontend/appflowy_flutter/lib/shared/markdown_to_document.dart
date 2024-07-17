import 'package:appflowy/plugins/document/presentation/editor_plugins/parsers/markdown_parsers.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

Document customMarkdownToDocument(String markdown) {
  return markdownToDocument(
    markdown,
    markdownParsers: [
      const MarkdownCodeBlockParser(),
      const MarkdownCustomImageParser(),
    ],
  );
}
