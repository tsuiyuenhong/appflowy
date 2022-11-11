import 'dart:collection';
import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/extensions/color_extension.dart';
import 'package:appflowy_editor/src/plugins/html/html_tags.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as html;

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
    final List<Node> result = [];
    for (var node in nodes) {
      if (node is html.Element) {
        if (node.localName == HTMLTag.paragraph) {
          result.add(_convertParagraphNode(node));
        } else if (node.localName == HTMLTag.anchor) {
          result.addAll(_convertAnchorNode(node));
        }
      } else if (node is html.Text) {
        // leaf node

      }
    }
    return result;
  }

  TextNode _convertParagraphNode(html.Node node) {
    final delta = Delta();
    for (final child in node.nodes) {
      _acceptInlineElement(delta, child, {});
    }
    return TextNode(delta: delta);
  }

  List<Node> _convertAnchorNode(html.Node node) {
    if (node.nodes.length == 1) {
      final delta = Delta();
      _acceptInlineElement(delta, node.nodes.first, {});
      return [
        TextNode(delta: delta),
      ];
    }

    return _convertHTMLNodes(node.nodes);
  }

  // List<Node> _convertHTMLNodes(List<html.Node> nodes) {
  //   final delta = Delta();
  //   final result = <Node>[];
  //   for (final node in nodes) {
  //     if (node is html.Element) {
  //       if (HTMLTag.inlineTags.contains(node.localName)) {
  //         _acceptInlineElement(delta, node);
  //       } else if (HTMLTag.bold == node.localName) {
  //         if (!_inParagraph) {
  //           // Google docs wraps the the content inside the `<b></b>` tag.
  //           // It's strange
  //           result.addAll(_convertHTMLNodes(node.children));
  //         } else {
  //           result.add(_convertElementToTextNode(node, null));
  //         }
  //       } else {
  //         result.addAll(_convertBlockElementToNode(node, null));
  //       }
  //     } else {
  //       delta.insert(node.text ?? '');
  //     }
  //   }
  //   if (delta.isNotEmpty) {
  //     result.add(TextNode(delta: delta));
  //   }
  //   return result;
  // }

  List<Node> _convertBlockElementToNode(
    html.Element element,
    Map<String, dynamic>? attributes,
  ) {
    switch (element.localName) {
      case HTMLTag.h1:
      case HTMLTag.h2:
      case HTMLTag.h3:
        return [_convertElementToHeadingNode(element, element.localName!)];
      case HTMLTag.unorderedList:
        return _convertElementToBulletedList(element);
      case HTMLTag.orderedList:
        return _convertElementToNumberList(element);
      case HTMLTag.list:
        return _convertElementsToNodes(element, attributes);
      case HTMLTag.paragraph:
        return _convertElementToParagraphNode(element, attributes);
      case HTMLTag.image:
        return [_convertElementToImageNode(element)];
      case HTMLTag.blockQuote:
        return _convertElementToQuotedTextNode(element);
      default:
        return [_convertElementToTextNode(element, attributes)];
    }
  }

  List<Node> _convertElementToQuotedTextNode(html.Element element) {
    final result = <Node>[];
    for (final node in element.nodes) {
      if (node is html.Element) {
        result.addAll(
          _convertBlockElementToNode(
            node,
            {BuiltInAttributeKey.subtype: BuiltInAttributeKey.quote},
          ),
        );
      } else if (node.text != null) {
        result.add(
          TextNode(
            delta: Delta()..insert(node.text!),
            attributes: {
              BuiltInAttributeKey.subtype: BuiltInAttributeKey.quote
            },
          ),
        );
      }
    }
    return result;
  }

  List<Node> _convertElementToParagraphNode(
    html.Element element,
    Map<String, dynamic>? attributes,
  ) {
    _inParagraph = true;
    final nodes = _convertHTMLNodes(element.children);
    _inParagraph = false;
    return nodes;
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
    final image = element.querySelector(HTMLTag.image);
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
        result.addAll(_convertBlockElementToNode(node, attributes));
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
        _acceptInlineElement(delta, node, {});
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

  void _acceptInlineElement(
    Delta delta,
    html.Node node,
    Attributes? attributes,
  ) {
    attributes ??= {};
    String text = node.text ?? '';
    if (node is html.Element) {
      switch (node.localName) {
        case HTMLTag.span:
          attributes.addAll(
            _converHTMLAttributesToDeltaAttributes(node.attributes) ?? {},
          );
          break;
        case HTMLTag.anchor:
          final href = node.attributes['href'];
          attributes.addAll({BuiltInAttributeKey.href: href});
          break;
        case HTMLTag.bold:
        case HTMLTag.strong:
          attributes.addAll({BuiltInAttributeKey.bold: true});
          break;
        case HTMLTag.underline:
          attributes.addAll({BuiltInAttributeKey.underline: true});
          break;
        case HTMLTag.italic:
          attributes.addAll({BuiltInAttributeKey.italic: true});
          break;
        case HTMLTag.del:
          attributes.addAll({BuiltInAttributeKey.strikethrough: true});
          break;
        case HTMLTag.code:
          attributes.addAll({BuiltInAttributeKey.code: true});
          break;
        default:
      }
      for (final child in node.nodes) {
        _acceptInlineElement(delta, child, attributes);
      }
    } else {
      delta.insert(text, attributes: attributes);
    }
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
