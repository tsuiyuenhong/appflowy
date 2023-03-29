import 'dart:convert';

import 'package:appflowy/plugins/document/presentation/plugins/parsers/math_equation_markdown_parser.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:intl/intl.dart';

class PluginDescription {
  const PluginDescription({
    required this.id,
    required this.name,
    required this.author,
    required this.version,
    required this.timestamp,
    required this.oneLineDescription,
    this.markdownDescription,
    this.documentJsonDescription,
  });

  final String id;

  // name of the plugin
  final String name;

  // author of the plugin
  final String author;

  // timestamp of the last update, millseconds since epoch
  final int timestamp;

  // version of the plugin
  final String version;

  // one line description of the plugin
  final String oneLineDescription;

  // description of the plugin with markdown format
  final String? markdownDescription;

  // description of the plugin with document json format
  final String? documentJsonDescription;

  static DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  String get lastUpdated => dateFormatter.format(
        DateTime.fromMillisecondsSinceEpoch(timestamp),
      );

  Document get document {
    assert(
      (markdownDescription == null) != (documentJsonDescription == null),
    );
    if (markdownDescription != null) {
      return markdownToDocument(
        markdownDescription!,
        customParsers: [
          MathEquationMarkdownParser(),
        ],
      );
    } else if (documentJsonDescription != null) {
      return Document.fromJson(jsonDecode(documentJsonDescription!));
    }
    return Document.empty();
  }
}
