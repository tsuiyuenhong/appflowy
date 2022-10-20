import 'package:appflowy_editor/appflowy_editor.dart';

abstract class NodeParser {
  String get id;
  String transform(Node node);
}

class TextNodeParser extends NodeParser {
  @override
  String get id => 'text';

  @override
  String transform(Node node) {
    assert(node is TextNode);
    var result = '';
    final textNode = node as TextNode;
    for (final op in textNode.delta) {
      assert(op is TextInsert);
      if (op is TextInsert) {
        final attributes = op.attributes;
        if (attributes != null) {
          if (attributes.containsKey(BuiltInAttributeKey.bold)) {}
        } else {
          result += op.text;
        }
      }
    }
    return result;
  }
}

class MarkdownEncoder {
  MarkdownEncoder({
    required this.parsers,
  });

  final List<NodeParser> parsers;
}
