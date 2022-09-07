import 'package:flutter/material.dart';

import 'package:appflowy_editor/src/document/node.dart';
import 'package:appflowy_editor/src/render/rich_text/rich_text_style.dart';

typedef StyleCustomizer = dynamic Function(Node node, NodeStyle defaultStyle);

dynamic _builtInStyleCustomizer(Node node) {
  if (node.type == 'text' && node.subtype == 'heading') {
    return NodeStyle.heading(hX: node.attributes.heading);
  } else if (node.type == 'text' && node.subtype == 'checkbox') {
    final normalStyle = NodeStyle.normal();
    return normalStyle.copyWith(
      textStyle: normalStyle.textStyle.copyWith(
        color: node.attributes.check ? Colors.grey : Colors.black,
      ),
    );
  }
  return null;
}

/// Editor style configuration
class EditorStyle {
  const EditorStyle({
    required this.padding,
    required this.styleCustomizer,
  });

  const EditorStyle.defaultStyle()
      : padding = const EdgeInsets.fromLTRB(200.0, 0.0, 200.0, 0.0),
        styleCustomizer = null;

  /// The margin of the document context from the editor.
  final EdgeInsets padding;

  final StyleCustomizer? styleCustomizer;

  dynamic style(Node node) {
    final defaultStyle = _builtInStyleCustomizer(node);
    if (styleCustomizer != null) {
      final style = styleCustomizer!(node, defaultStyle);
      if (style != null) {
        return style;
      }
    }
    return defaultStyle;
  }

  EditorStyle copyWith({
    EdgeInsets? padding,
    StyleCustomizer? styleCustomizer,
  }) {
    final ret = EditorStyle(
      padding: padding ?? this.padding,
      styleCustomizer: styleCustomizer ?? this.styleCustomizer,
    );
    return ret;
  }
}

class NodeStyle {
  NodeStyle.normal({
    this.padding = const EdgeInsets.symmetric(horizontal: 5.0),
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
    ),
    this.placeholderText = 'Type something...',
  });

  NodeStyle._({
    required this.padding,
    required this.textStyle,
    required this.placeholderText,
  });

  factory NodeStyle.heading({String? hX = ''}) => NodeStyle.normal().copyWith(
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        placeholderText: 'Heading $hX',
      );

  final EdgeInsets padding;
  final TextStyle textStyle;
  final String placeholderText;

  NodeStyle copyWith({
    EdgeInsets? padding,
    TextStyle? textStyle,
    String? placeholderText,
  }) {
    return NodeStyle._(
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      placeholderText: placeholderText ?? this.placeholderText,
    );
  }
}
