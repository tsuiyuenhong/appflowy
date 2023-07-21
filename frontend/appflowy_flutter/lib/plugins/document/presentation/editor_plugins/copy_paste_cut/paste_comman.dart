import 'package:appflowy/plugins/document/presentation/editor_plugins/copy_paste_cut/in_app_cop_paste_format.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';

/// Customize the paste command for AppFlowy
///
/// Supports paste the content from
///   - html
///   - plain text
///   - in-app format, json
CommandShortcutEvent customPasteCommand = CommandShortcutEvent(
  key: 'paste',
  command: 'ctrl+v',
  macOSCommand: 'cmd+v',
  handler: _handler,
);

CommandShortcutEventHandler _handler = (editorState) {
  var selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  // delete the selection first.
  if (!selection.isCollapsed) {
    editorState.deleteSelection(selection);
  }

  // fetch selection again.
  selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.skipRemainingHandlers;
  }
  assert(selection.isCollapsed);

  editorState.paste();

  return KeyEventResult.handled;
};

extension on EditorState {
  Future<void> paste() async {
    final selection = this.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }
    final next = selection.start.path.next;
    final reader = await ClipboardReader.readClipboard();

    // in-app format
    if (reader.canProvide(appFlowyInAppCopyPasteFormat)) {
      final json = await reader.readValue(appFlowyInAppCopyPasteFormat);
      if (json != null) {
        final document = Document.fromJson(json);
        await insertNodesAtCurrentSelection(document.root.children);
        return;
      }
    }

    // html
    if (reader.canProvide(Formats.htmlText)) {
      final html = await reader.readValue(Formats.htmlText);
      if (html != null) {
        final document = htmlToDocument(html);
        await insertNodesAtCurrentSelection(document.root.children);
        return;
      }
    }

    // plaintext
    if (reader.canProvide(Formats.plainText)) {
      final text = await reader.readValue(Formats.plainText);
      if (text != null) {
        await insertNodesAtCurrentSelection(
          text.split('\n').map((e) => paragraphNode(text: e)),
        );
        return;
      }
    }
  }

  /// insert nodes at current selection
  Future<void> insertNodesAtCurrentSelection(Iterable<Node> nodes) async {
    final selection = this.selection;
    if (selection == null || nodes.isEmpty) {
      return;
    }

    final first = nodes.first;
    // if the first node contains text, delete the selection.
    if (first.delta != null) {
      await deleteSelection(selection);
      assert(selection.isCollapsed);
      final current = getNodeAtPath(selection.start.path);
      if (current == null) {
        return;
      }
      final first = nodes.first;
      if (first.delta != null) {
        final delta = current.delta!.slice(0, selection.start.offset);
        first.delta!.whereType<TextInsert>().forEach((element) {
          delta.insert(element.text, attributes: element.attributes);
        });
        first.updateAttributes({
          blockComponentDelta: delta.toJson(),
        });
      }
      final last = nodes.last;
      if (last.delta != null) {
        final delta = current.delta!.slice(
          selection.start.offset,
          current.delta!.length,
        );
        final lastDelta = last.delta!;
        delta.whereType<TextInsert>().forEach((element) {
          lastDelta.insert(element.text, attributes: element.attributes);
        });
        last.updateAttributes({
          blockComponentDelta: lastDelta.toJson(),
        });
      }
      final transaction = this.transaction
        ..insertNodes(selection.start.path, nodes)
        ..deleteNode(current);
      await apply(transaction);
    } else {
      // if the first node is not text, insert the nodes after the selection.
      final next = selection.start.path.next;
      final transaction = this.transaction
        ..insertNodes(next, nodes)
        ..afterSelection = Selection(
          start: Position(path: next),
          end: Position(path: next.parent + [next.last + nodes.length]),
        );
      return apply(transaction);
    }
  }
}
