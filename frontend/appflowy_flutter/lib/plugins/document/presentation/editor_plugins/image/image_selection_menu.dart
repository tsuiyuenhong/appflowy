import 'package:appflowy/plugins/document/presentation/editor_plugins/image/custom_image_block_component.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/image/image_placeholder.dart';
import 'package:appflowy_editor/appflowy_editor.dart' hide Log;
import 'package:flutter/material.dart';

final customImageMenuItem = SelectionMenuItem(
  name: AppFlowyEditorLocalizations.current.image,
  icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
    name: 'image',
    isSelected: isSelected,
    style: style,
  ),
  keywords: ['image', 'picture', 'img', 'photo'],
  handler: (editorState, menuService, context) async {
    final key = GlobalKey();
    await editorState.insertImagePlaceholderBlock(key);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // show the image popover menu
      final state = key.currentState;
      if (state != null && state is ImagePlaceholderState) {
        state.controller.show();
      }
    });
  },
);

extension on EditorState {
  Future<Node?> insertImagePlaceholderBlock(GlobalKey key) async {
    final selection = this.selection;
    if (selection == null || !selection.isCollapsed) {
      return null;
    }
    final node = getNodeAtPath(selection.end.path);
    if (node == null) {
      return null;
    }
    final insertedNode = imageNode(url: '')
      ..externalValues = ImageExternalValues(key: key);
    final transaction = this.transaction;
    // if the current node is empty paragraph, replace it with image node
    if (node.type == ParagraphBlockKeys.type &&
        (node.delta?.isEmpty ?? false)) {
      transaction
        ..insertNode(
          node.path,
          insertedNode,
        )
        ..deleteNode(node);
    } else {
      transaction.insertNode(
        node.path.next,
        insertedNode,
      );
    }

    transaction.afterSelection = Selection.collapsed(
      Position(
        path: node.path.next,
        offset: 0,
      ),
    );

    await apply(transaction);

    return insertedNode;
  }
}
