import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/src/table/table_node_widget.dart';
import 'package:flutter/material.dart';

SelectionMenuItem tableMenuItem = SelectionMenuItem(
  name: () => 'Table',
  icon: (editorState, onSelected) => Icon(
    Icons.table_chart_outlined,
    color: onSelected
        ? editorState.editorStyle.selectionMenuItemSelectedIconColor
        : editorState.editorStyle.selectionMenuItemIconColor,
    size: 18.0,
  ),
  keywords: ['table'],
  handler: (editorState, _, __) {
    final selection =
        editorState.service.selectionService.currentSelection.value;
    final textNodes = editorState.service.selectionService.currentSelectedNodes
        .whereType<TextNode>();
    if (selection == null || textNodes.isEmpty) {
      return;
    }
    final transaction = editorState.transaction;
    transaction.insertNode(
      selection.end.path,
      Node(
        type: kTableType,
      ),
    );
    transaction.afterSelection = selection;
    editorState.apply(transaction);
  },
);
