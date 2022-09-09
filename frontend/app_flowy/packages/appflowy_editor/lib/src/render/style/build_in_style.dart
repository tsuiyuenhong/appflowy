import 'package:flutter/material.dart';

import 'package:appflowy_editor/src/render/rich_text/rich_text_style.dart';
import 'package:appflowy_editor/src/render/style/editor_style.dart';

Map<String, StyleCustomizer> builtInStyleCustomizer = {
  'text': ((_, __) {
    return BuiltInNodeStyle.normal();
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
        color: check ? Colors.grey : Colors.black,
      ),
      placeholderText: 'To-Do',
      iconPadding: const EdgeInsets.only(right: 5.0),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
    this.padding = const EdgeInsets.symmetric(vertical: 5.0),
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 18.0,
    ),
    this.placeHolderTextStyle = const TextStyle(
      color: Colors.grey,
      fontSize: 18.0,
    ),
    this.placeholderText = 'Type something...',
    this.iconSize = const Size.square(24.0),
    this.iconPadding = const EdgeInsets.all(0.0),
  });

  BuiltInNodeStyle._({
    required this.padding,
    required this.textStyle,
    required this.placeHolderTextStyle,
    required this.placeholderText,
    this.iconSize = const Size.square(24.0),
    this.iconPadding = const EdgeInsets.all(0.0),
  });

  final EdgeInsets padding;
  final TextStyle textStyle;
  final TextStyle placeHolderTextStyle;
  final String placeholderText;
  final Size? iconSize;
  final EdgeInsets? iconPadding;

  BuiltInNodeStyle copyWith({
    EdgeInsets? padding,
    TextStyle? textStyle,
    TextStyle? placeHolderTextStyle,
    String? placeholderText,
    Size? iconSize,
    EdgeInsets? iconPadding,
  }) {
    return BuiltInNodeStyle._(
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      placeHolderTextStyle: placeHolderTextStyle ?? this.placeHolderTextStyle,
      placeholderText: placeholderText ?? this.placeholderText,
      iconSize: iconSize ?? this.iconSize,
      iconPadding: iconPadding ?? this.iconPadding,
    );
  }
}
