import 'package:appflowy_editor/src/document/node.dart';
import 'package:appflowy_editor/src/render/rich_text/rich_text_style.dart';
import 'package:flutter/material.dart';

typedef StyleCustomizer = dynamic Function(Node node);

dynamic _builtInStyleCustomizer(Node node) {
  if (node is TextNode && node.subtype == 'heading') {
    return NodeStyle.heading(hX: node.attributes.heading);
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
    if (styleCustomizer != null) {
      return styleCustomizer!(node);
    }
    return _builtInStyleCustomizer(node);
  }

  EditorStyle copyWith({EdgeInsets? padding}) {
    return EditorStyle(
      padding: padding ?? this.padding,
      styleCustomizer: styleCustomizer ?? styleCustomizer,
    );
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
