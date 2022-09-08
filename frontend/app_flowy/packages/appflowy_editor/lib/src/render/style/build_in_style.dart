import 'package:appflowy_editor/src/render/style/editor_style.dart';
import 'package:flutter/material.dart';

import 'package:appflowy_editor/src/render/rich_text/rich_text_style.dart';

Map<String, StyleCustomizer> builtInStyleCustomizer = {
  'text': ((_, __) {
    BuiltInNodeStyle.normal();
  }),
  'text/checkbox': ((node, __) {
    final normalStyle = BuiltInNodeStyle.normal();
    final check = node.attributes.check;
    final decoration = normalStyle.textStyle.decoration;
    return normalStyle.copyWith(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      textStyle: normalStyle.textStyle.copyWith(
        decoration: check
            ? TextDecoration.combine([
                TextDecoration.lineThrough,
                if (decoration != null) decoration
              ])
            : decoration,
      ),
      placeholderText: 'To-Do',
    );
  }),
  'text/heading': ((node, __) {
    final normalStyle = BuiltInNodeStyle.normal();
    final x = node.attributes.heading?.replaceAll('h', '');
    final level = x != null ? int.parse(x) : -1;
    final List<double> fontSizes = [32, 28, 24, 18, 18, 18];
    final fontSize =
        level >= 0 && level < fontSizes.length ? fontSizes[level] : null;
    return normalStyle.copyWith(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      textStyle: normalStyle.textStyle.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
      placeholderText: 'Heading $x',
    );
  }),
  'text/bulleted-list': ((_, __) {
    BuiltInNodeStyle.normal();
  }),
  'text/number-list': ((_, __) {
    BuiltInNodeStyle.normal();
  }),
  'text/quote': ((_, __) {
    BuiltInNodeStyle.normal();
  }),
  'image': ((_, __) {
    BuiltInNodeStyle.normal();
  }),
};

class BuiltInNodeStyle extends NodeStyle {
  BuiltInNodeStyle.normal({
    this.padding = const EdgeInsets.symmetric(horizontal: 5.0),
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 18.0,
      fontWeight: FontWeight.normal,
    ),
    this.placeholderText = 'Type something...',
  });

  BuiltInNodeStyle._({
    required this.padding,
    required this.textStyle,
    required this.placeholderText,
  });

  final EdgeInsets padding;
  final TextStyle textStyle;
  final String placeholderText;

  BuiltInNodeStyle copyWith({
    EdgeInsets? padding,
    TextStyle? textStyle,
    String? placeholderText,
  }) {
    return BuiltInNodeStyle._(
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      placeholderText: placeholderText ?? this.placeholderText,
    );
  }
}
