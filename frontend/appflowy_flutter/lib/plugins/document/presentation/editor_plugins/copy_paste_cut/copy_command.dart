import 'package:appflowy/plugins/document/presentation/editor_plugins/copy_paste_cut/in_app_cop_paste_format.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';

/// Customize the copy command for AppFlowy
///
/// Supports copy the content to
///   - html
///   - plain text
///   - in-app format, json
CommandShortcutEvent customCopyCommand = CommandShortcutEvent(
  key: 'copy',
  command: 'ctrl+c',
  macOSCommand: 'cmd+c',
  handler: _handler,
);

CommandShortcutEventHandler _handler = (editorState) {
  // If the selection is null or collapsed, do nothing.
  final selection = editorState.selection?.normalized;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  final nodes = editorState.getSlicedNodeInSelection(selection);
  final document = Document.blank()..insert([0], nodes);

  // plain text
  final plainText =
      nodes.map((e) => e.delta?.toPlainText()).whereNotNull().join('\n');

  // html
  final html = documentToHTML(document);

  // in-app format
  // final json = jsonEncode(document.toJson());
  final json = document.toJson();

  final item = DataWriterItem();
  item.add(appFlowyInAppCopyPasteFormat(json));
  item.add(Formats.plainText(plainText));
  item.add(Formats.htmlText(html));
  ClipboardWriter.instance.write([item]);

  return KeyEventResult.handled;
};

extension on EditorState {
  List<Node> getSlicedNodeInSelection(Selection selection) {
    final res = <Node>[];
    if (selection.isCollapsed) {
      return res;
    }
    final nodes = getNodesInSelection(selection);
    for (final node in nodes) {
      final delta = node.delta;
      if (delta == null) {
        res.add(node);
      } else {
        final startIndex = node == nodes.first ? selection.startIndex : 0;
        final endIndex = node == nodes.last ? selection.endIndex : delta.length;
        res.add(
          node.copyWith(
            attributes: {
              ...node.attributes,
              blockComponentDelta: delta.slice(startIndex, endIndex).toJson(),
            },
          ),
        );
      }
    }
    return res;
  }
}
