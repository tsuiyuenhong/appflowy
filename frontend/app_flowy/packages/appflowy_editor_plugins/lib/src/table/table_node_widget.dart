import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

const String kTableType = 'table';

class TableNodeWidgetBuilder extends NodeWidgetBuilder<Node> {
  @override
  Widget build(NodeWidgetContext<Node> context) {
    return _TableNodeWidget(
      key: context.node.key,
      node: context.node,
      editorState: context.editorState,
    );
  }

  @override
  NodeValidator<Node> get nodeValidator => (node) {
        return true;
      };
}

class _TableNodeWidget extends StatefulWidget {
  const _TableNodeWidget({
    Key? key,
    required this.node,
    required this.editorState,
  }) : super(key: key);

  final Node node;
  final EditorState editorState;

  @override
  State<_TableNodeWidget> createState() => _TableNodeWidgetState();
}

class _TableNodeWidgetState extends State<_TableNodeWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildChildren(context),
      ],
    );
  }

  Widget _buildChildren(BuildContext context) {
    final datasource = widget.node.children.map((e) => e as TextNode);
    // .map((e) => e.toPlainText());
    final children = datasource.fold<List<Widget>>(
      [],
      (previousValue, element) => [
        ...previousValue,
        Container(
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child:
              widget.editorState.service.renderPluginService.buildPluginWidget(
            NodeWidgetContext<TextNode>(
              context: context,
              node: element,
              editorState: widget.editorState,
            ),
          ),
        ),
      ],
    );
    return Row(
      children: children,
    );
  }
}
