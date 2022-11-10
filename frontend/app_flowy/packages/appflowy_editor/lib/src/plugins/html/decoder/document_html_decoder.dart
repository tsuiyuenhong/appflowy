import 'dart:collection';
import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/extensions/color_extension.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as html;

class _HTMLTag {
  static const h1 = 'h1';
  static const h2 = 'h2';
  static const h3 = 'h3';

  static const blockQuote = 'blockquote';
  static const orderedList = 'ol';
  static const unorderedList = 'ul';
  static const list = 'li';

  static const paragraph = 'p';
  static const image = 'img';
  static const div = 'div';

  static const anchor = 'a';
  static const italic = 'i';
  static const bold = 'b';
  static const underline = 'u';
  static const del = 'del';
  static const strong = 'strong';
  static const span = 'span';
  static const code = 'code';

  static bool isTopLevel(String tag) {
    return tag == h1 ||
        tag == h2 ||
        tag == h3 ||
        tag == paragraph ||
        tag == div ||
        tag == blockQuote;
  }

  static List<String> inlineTags = [
    anchor,
    span,
    code,
    strong,
    underline,
    italic,
    del,
  ];
}

class DocumentHTMLDecoder extends Converter<String, Document> {
  /// This flag is used for parsing HTML pasting from Google Docs
  /// Google docs wraps the the content inside the `<b></b>` tag. It's strange.
  ///
  /// If a `<b>` element is parsing in the <p>, we regard it as as text spans.
  /// Otherwise, it's parsed as a container.
  bool _inParagraph = false;

  @override
  Document convert(String input) {
    final document = parse(input);
    List<html.Node>? nodes = document.body?.nodes;
    if (nodes != null && nodes.isNotEmpty) {
      return Document.empty()..insert([0], _convertHTMLNodes(nodes));
    }
    return Document.empty();
  }

  List<Node> _convertHTMLNodes(List<html.Node> nodes) {
    final delta = Delta();
    final result = <Node>[];
    for (final node in nodes) {
      if (node is html.Element) {
        if (_HTMLTag.inlineTags.contains(node.localName)) {
          _acceptInlineElement(delta, node);
        } else if (_HTMLTag.bold == node.localName) {
          if (!_inParagraph) {
            // Google docs wraps the the content inside the `<b></b>` tag.
            // It's strange
            result.addAll(_convertHTMLNodes(node.children));
          } else {
            result.add(_convertElementToTextNode(node, null));
          }
        } else if (_HTMLTag.blockQuote == node.localName) {
          result.addAll(_convertElementToQuotedTextNode(node));
        } else {
          result.addAll(_convertBlockElementToNode(node, null));
        }
      } else {
        delta.insert(node.text ?? '');
      }
    }
    if (delta.isNotEmpty) {
      result.add(TextNode(delta: delta));
    }
    return result;
  }

  List<Node> _convertBlockElementToNode(
    html.Element element,
    Map<String, dynamic>? attributes,
  ) {
    switch (element.localName) {
      case _HTMLTag.h1:
      case _HTMLTag.h2:
      case _HTMLTag.h3:
        return [_convertElementToHeadingNode(element, element.localName!)];
      case _HTMLTag.unorderedList:
        return _convertElementToBulletedList(element);
      case _HTMLTag.orderedList:
        return _convertElementToNumberList(element);
      case _HTMLTag.list:
        return _convertElementsToNodes(element, attributes);
      case _HTMLTag.paragraph:
        return [_convertElementToParagraphNode(element, attributes)];
      case _HTMLTag.image:
        return [_convertElementToImageNode(element)];
      case _HTMLTag.blockQuote:
        return _convertElementToQuotedTextNode(element);
      default:
        return [_convertElementToTextNode(element, attributes)];
    }
  }

  List<Node> _convertElementToQuotedTextNode(html.Element element) {
    final result = <Node>[];
    for (final child in element.nodes.toList()) {
      if (child is html.Element) {
        result.addAll(
          _convertBlockElementToNode(
            child,
            {BuiltInAttributeKey.subtype: BuiltInAttributeKey.quote},
          ),
        );
      }
    }
    return result;
  }

  Node _convertElementToParagraphNode(
    html.Element element,
    Map<String, dynamic>? attributes,
  ) {
    _inParagraph = true;
    final node = _convertElementToTextNode(element, attributes);
    _inParagraph = false;
    return node;
  }

  Node _convertElementToHeadingNode(html.Element element, String heading) {
    return TextNode(
      delta: Delta()..insert(element.text),
      attributes: {
        BuiltInAttributeKey.subtype: BuiltInAttributeKey.heading,
        BuiltInAttributeKey.heading: heading,
      },
    );
  }

  /// A container contains a <input type="checkbox" > will
  /// be regarded as a checkbox block.
  ///
  /// A container contains a <img /> will be regarded as a image block
  Node _convertElementToTextNode(html.Element element, Attributes? attributes) {
    final image = element.querySelector(_HTMLTag.image);
    if (image != null) {
      return _convertElementToImageNode(image);
    }
    return _convertElementToCheckboxNode(element, attributes);
  }

  List<Node> _convertElementToBulletedList(html.Element element) {
    final result = <Node>[];
    for (var child in element.children) {
      result.addAll(
        _convertElementsToNodes(child, {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.bulletedList,
        }),
      );
    }
    return result;
  }

  List<Node> _convertElementToNumberList(html.Element element) {
    final result = <Node>[];
    for (var i = 0; i < element.children.length; i++) {
      final child = element.children[i];
      result.addAll(
        _convertElementsToNodes(child, {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.numberList,
          BuiltInAttributeKey.number: i + 1
        }),
      );
    }
    return result;
  }

  List<Node> _convertElementsToNodes(
      html.Element element, Map<String, dynamic>? attributes) {
    final result = <Node>[];
    final nodes = element.nodes;
    for (final node in nodes) {
      if (node is html.Element) {
        result.addAll(_convertHTMLNodes([node]));
      }
    }
    return result;
  }

  Node _convertElementToImageNode(html.Element element) {
    final src = element.attributes['src'];
    if (src != null) {
      return Node(
        type: 'image',
        attributes: {'image_src': src},
      );
    }
    return TextNode.empty();
  }

  Node _convertElementToCheckboxNode(
    html.Element element,
    Attributes? attributes,
  ) {
    final delta = Delta();
    for (final node in element.nodes) {
      if (node is html.Element) {
        _acceptInlineElement(delta, node);
      } else {
        delta.insert(node.text ?? "");
      }
    }

    final input = element.querySelector('input');
    bool checked = false;
    final isCheckbox = input != null && input.attributes['type'] == 'checkbox';
    if (isCheckbox) {
      checked = input.attributes['checked'] != 'false';
    }
    return TextNode(
      delta: delta,
      attributes: {
        if (attributes != null) ...attributes,
        if (isCheckbox) ...{
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.checkbox,
          BuiltInAttributeKey.checkbox: checked,
        }
      },
    );
  }

  void _acceptInlineElement(Delta delta, html.Element element) {
    Attributes? attributes;
    switch (element.localName) {
      case _HTMLTag.span:
        attributes = _converHTMLAttributesToDeltaAttributes(element.attributes);
        break;
      case _HTMLTag.anchor:
        final href = element.attributes['href'];
        attributes = {BuiltInAttributeKey.href: href};
        break;
      case _HTMLTag.bold:
      case _HTMLTag.strong:
        attributes = {BuiltInAttributeKey.bold: true};
        break;
      case _HTMLTag.underline:
        attributes = {BuiltInAttributeKey.underline: true};
        break;
      case _HTMLTag.italic:
        attributes = {BuiltInAttributeKey.italic: true};
        break;
      case _HTMLTag.del:
        attributes = {BuiltInAttributeKey.strikethrough: true};
        break;
      case _HTMLTag.code:
        attributes = {BuiltInAttributeKey.code: true};
        break;
      default:
    }
    delta.insert(element.text, attributes: attributes);
  }

  /// Convert HTML attributes to Delta attributes
  Attributes? _converHTMLAttributesToDeltaAttributes(
    LinkedHashMap<Object, String> htmlAttributes,
  ) {
    final attributes = <String, dynamic>{};
    final cssMap = _convertCssStringToMap(htmlAttributes['style']);

    final fontWeiget = cssMap['font-weight'];
    if (fontWeiget != null) {
      if (fontWeiget == 'bold') {
        attributes[BuiltInAttributeKey.bold] = true;
      } else {
        final weight = int.tryParse(fontWeiget);
        if (weight != null && weight > 500) {
          attributes[BuiltInAttributeKey.bold] = true;
        }
      }
    }

    final textDecoration = cssMap['text-decoration'];
    if (textDecoration != null) {
      final textDecorations = textDecoration.split(' ');
      for (final textDecoration in textDecorations) {
        switch (textDecoration) {
          case 'underline':
            attributes[BuiltInAttributeKey.underline] = true;
            break;
          case 'line-through':
            attributes[BuiltInAttributeKey.strikethrough] = true;
            break;
          default:
            break;
        }
      }
    }

    final backgroundColor =
        ColorExtension.tryFromRgbaString(cssMap['background-color']);
    if (backgroundColor != null) {
      attributes[BuiltInAttributeKey.backgroundColor] =
          '0x${backgroundColor.value.toRadixString(16)}';
    }

    if (cssMap['font-style'] == 'italic') {
      attributes[BuiltInAttributeKey.italic] = true;
    }

    return attributes.isEmpty ? null : attributes;
  }

  /// Convert CSS string to Map
  Map<String, String> _convertCssStringToMap(String? cssString) {
    if (cssString == null) {
      return {};
    }
    return cssString
        .split(';')
        .map((e) => e.split(':'))
        .where((e) => e.length >= 2)
        .fold<Map<String, String>>(
      {},
      (previousValue, element) => {
        ...previousValue,
        element[0].trim(): element[1].trim(),
      },
    );
  }
}
