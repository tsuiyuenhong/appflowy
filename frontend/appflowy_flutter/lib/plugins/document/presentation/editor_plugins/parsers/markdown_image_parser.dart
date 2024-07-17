import 'package:appflowy/plugins/document/presentation/editor_plugins/image/custom_image_block_component.dart';
import 'package:appflowy_editor/appflowy_editor.dart' hide imageNode;
import 'package:markdown/markdown.dart' as md;

class MarkdownCustomImageParser extends CustomMarkdownParser {
  const MarkdownCustomImageParser();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
    if (element is! md.Element) {
      return [];
    }

    if (element.children?.length != 1 ||
        element.children?.first is! md.Element) {
      return [];
    }

    final ec = element.children?.first as md.Element;
    if (ec.tag != 'img' || ec.attributes['src'] == null) {
      return [];
    }

    return [
      customImageNode(url: ec.attributes['src']!),
    ];
  }
}
