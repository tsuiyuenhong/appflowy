import 'package:appflowy_editor/src/render/style/build_in_style.dart';
import 'package:flutter/material.dart';

import 'package:appflowy_editor/src/document/node.dart';

typedef StyleCustomizer = dynamic Function(Node node, NodeStyle? defaultStyle);

abstract class NodeStyle {}

/// Editor style configuration
class EditorStyle {
  const EditorStyle({
    required this.padding,
    required this.styleCustomizers,
  });

  const EditorStyle.defaultStyle()
      : padding = const EdgeInsets.fromLTRB(200.0, 0.0, 200.0, 0.0),
        styleCustomizers = const {};

  /// The margin of the document context from the editor.
  final EdgeInsets padding;

  final Map<String, StyleCustomizer> styleCustomizers;

  dynamic style(Node node) {
    final builtInStyle = builtInStyleCustomizer[node.id];
    final style = builtInStyle != null ? builtInStyle(node, null) : null;
    if (styleCustomizers.containsKey(node.id)) {
      return styleCustomizers[node.id]!(
        node,
        style,
      );
    }
    return style;
  }

  EditorStyle copyWith({
    EdgeInsets? padding,
    Map<String, StyleCustomizer>? styleCustomizers,
  }) {
    final ret = EditorStyle(
      padding: padding ?? this.padding,
      styleCustomizers: styleCustomizers ?? this.styleCustomizers,
    );
    return ret;
  }
}
