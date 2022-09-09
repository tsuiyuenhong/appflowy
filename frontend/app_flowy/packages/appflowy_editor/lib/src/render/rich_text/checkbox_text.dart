import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/infra/flowy_svg.dart';
import 'package:appflowy_editor/src/render/rich_text/default_selectable.dart';
import 'package:appflowy_editor/src/render/rich_text/flowy_rich_text.dart';
import 'package:flutter/material.dart';

class CheckboxNodeWidgetBuilder extends NodeWidgetBuilder<TextNode> {
  @override
  Widget build(NodeWidgetContext<TextNode> context) {
    return CheckboxNodeWidget(
      key: context.node.key,
      textNode: context.node,
      editorState: context.editorState,
    );
  }

  @override
  NodeValidator<Node> get nodeValidator => ((node) {
        return node.attributes.containsKey(StyleKey.checkbox);
      });
}

class CheckboxNodeWidget extends StatefulWidget {
  const CheckboxNodeWidget({
    Key? key,
    required this.textNode,
    required this.editorState,
  }) : super(key: key);

  final TextNode textNode;
  final EditorState editorState;

  @override
  State<CheckboxNodeWidget> createState() => _CheckboxNodeWidgetState();
}

class _CheckboxNodeWidgetState extends State<CheckboxNodeWidget>
    with SelectableMixin, DefaultSelectable {
  @override
  final iconKey = GlobalKey();

  final _richTextKey = GlobalKey(debugLabel: 'checkbox_text');

  BuiltInNodeStyle get _checkboxStyle =>
      widget.editorState.editorStyle.style(widget.textNode) as BuiltInNodeStyle;

  @override
  SelectableMixin<StatefulWidget> get forward =>
      _richTextKey.currentState as SelectableMixin;

  @override
  Widget build(BuildContext context) {
    if (widget.textNode.children.isEmpty) {
      return _buildWithSingle(context);
    } else {
      return _buildWithChildren(context);
    }
  }

  Widget _buildWithSingle(BuildContext context) {
    final check = widget.textNode.attributes.check;
    return Padding(
      padding: EdgeInsets.only(bottom: defaultLinePadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            key: iconKey,
            child: FlowySvg(
              width: _checkboxStyle.iconSize?.width ?? 20.0,
              height: _checkboxStyle.iconSize?.height ?? 20.0,
              padding: _checkboxStyle.iconPadding ?? EdgeInsets.zero,
              name: check ? 'check' : 'uncheck',
            ),
            onTap: () {
              TransactionBuilder(widget.editorState)
                ..updateNode(widget.textNode, {
                  StyleKey.checkbox: !check,
                })
                ..commit();
            },
          ),
          Flexible(
            child: FlowyRichText(
              key: _richTextKey,
              placeholderText: _checkboxStyle.placeholderText,
              textNode: widget.textNode,
              textSpanDecorator: _textSpanDecorator,
              placeholderTextSpanDecorator: _placeholderTextSpanDecorator,
              editorState: widget.editorState,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithChildren(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWithSingle(context),
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            Column(
              children: widget.textNode.children
                  .map(
                    (child) => widget.editorState.service.renderPluginService
                        .buildPluginWidget(
                      child is TextNode
                          ? NodeWidgetContext<TextNode>(
                              context: context,
                              node: child,
                              editorState: widget.editorState,
                            )
                          : NodeWidgetContext<Node>(
                              context: context,
                              node: child,
                              editorState: widget.editorState,
                            ),
                    ),
                  )
                  .toList(),
            )
          ],
        )
      ],
    );
  }

  TextSpan _textSpanDecorator(TextSpan textSpan) {
    return TextSpan(
      children: textSpan.children
          ?.whereType<TextSpan>()
          .map(
            (span) => TextSpan(
              text: span.text,
              style: span.style?.merge(_checkboxStyle.textStyle),
              recognizer: span.recognizer,
            ),
          )
          .toList(),
    );
  }

  TextSpan _placeholderTextSpanDecorator(TextSpan textSpan) {
    return TextSpan(
      children: textSpan.children
          ?.whereType<TextSpan>()
          .map(
            (span) => TextSpan(
              text: span.text,
              style: span.style?.merge(_checkboxStyle.placeHolderTextStyle),
              recognizer: span.recognizer,
            ),
          )
          .toList(),
    );
  }
}
