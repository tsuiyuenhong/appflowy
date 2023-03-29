import 'package:appflowy_editor/src/core/document/node.dart';

abstract class MarkdownParser {
  const MarkdownParser();

  Node? transform(String markdown);
}
