import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser/markdown_parser.dart';

class DocumentMarkdownDecoder extends Converter<String, Document> {
  DocumentMarkdownDecoder({
    this.parsers = const [],
  });

  final List<MarkdownParser> parsers;

  @override
  Document convert(String input) {
    final lines = input.split('\n');
    final document = Document.empty();

    var i = 0;
    for (final line in lines) {
      document.insert([i++], [_convertLineToNode(line)]);
    }

    return document;
  }

  Node _convertLineToNode(String text) {
    final decoder = DeltaMarkdownDecoder();

    Node? node;
    for (final parser in parsers) {
      node = parser.transform(text);
      if (node != null) {
        return node;
      }
    }

    // Heading Style
    if (text.startsWith('### ')) {
      return TextNode(
        delta: decoder.convert(text.substring(4)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.heading,
          BuiltInAttributeKey.heading: BuiltInAttributeKey.h3,
        },
      );
    } else if (text.startsWith('## ')) {
      return TextNode(
        delta: decoder.convert(text.substring(3)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.heading,
          BuiltInAttributeKey.heading: BuiltInAttributeKey.h2,
        },
      );
    } else if (text.startsWith('# ')) {
      return TextNode(
        delta: decoder.convert(text.substring(2)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.heading,
          BuiltInAttributeKey.heading: BuiltInAttributeKey.h1,
        },
      );
    } else if (text.startsWith('- [ ] ')) {
      return TextNode(
        delta: decoder.convert(text.substring(6)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.checkbox,
          BuiltInAttributeKey.checkbox: false,
        },
      );
    } else if (text.startsWith('- [x] ')) {
      return TextNode(
        delta: decoder.convert(text.substring(6)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.checkbox,
          BuiltInAttributeKey.checkbox: true,
        },
      );
    } else if (text.startsWith('> ')) {
      return TextNode(
        delta: decoder.convert(text.substring(2)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.quote,
        },
      );
    } else if (text.startsWith('- ') || text.startsWith('* ')) {
      return TextNode(
        delta: decoder.convert(text.substring(2)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.bulletedList,
        },
      );
    } else if (text.startsWith('> ')) {
      return TextNode(
        delta: decoder.convert(text.substring(2)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.quote,
        },
      );
    } else if (text.isNotEmpty && RegExp(r'^-*').stringMatch(text) == text) {
      return Node(type: 'divider');
    }

    if (text.isNotEmpty) {
      return TextNode(delta: decoder.convert(text));
    }

    return TextNode(delta: Delta());
  }
}
