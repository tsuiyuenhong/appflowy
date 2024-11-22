import 'package:appflowy/plugins/document/presentation/editor_plugins/table/simple_table_block_component.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/table/simple_table_cell_block_component.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/table/simple_table_constants.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/table/table_operations/table_node_extension.dart';
import 'package:appflowy_backend/log.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

extension TableOperations on EditorState {
  /// Delete a row at the given index.
  ///
  /// Before:
  /// Given index: 0
  /// Row 1: |   |   |   | ← This row will be deleted
  /// Row 2: |   |   |   |
  ///
  /// Call this function with index 0 will delete the first row of the table.
  ///
  /// After:
  /// Row 1: |   |   |   |
  Future<void> deleteRowInTable(
    Node node,
    int index,
  ) async {
    assert(node.type == SimpleTableBlockKeys.type);

    if (node.type != SimpleTableBlockKeys.type) {
      return;
    }

    final rowLength = node.columnLength;
    if (index < 0 || index >= rowLength) {
      Log.warn(
        'delete row: index out of range: $index, row length: $rowLength',
      );
      return;
    }

    Log.info('delete row: $index in table ${node.id}');

    final row = node.children[index];
    final transaction = this.transaction;
    transaction.deleteNode(row);
    await apply(transaction);
  }

  /// Delete a column at the given index.
  ///
  /// Before:
  /// Given index: 2
  ///                  ↓ This column will be deleted
  /// Row 1: | 0 | 1 | 2 |
  /// Row 2: |   |   |   |
  ///
  /// Call this function with index 2 will delete the third column of the table.
  ///
  /// After:
  /// Row 1: | 0 | 1 |
  /// Row 2: |   |   |
  Future<void> deleteColumnInTable(Node node, int index) async {
    assert(node.type == SimpleTableBlockKeys.type);

    if (node.type != SimpleTableBlockKeys.type) {
      return;
    }

    final rowLength = node.rowLength;
    final columnLength = node.columnLength;
    if (index < 0 || index >= columnLength) {
      Log.warn(
        'delete column: index out of range: $index, column length: $columnLength',
      );
      return;
    }

    Log.info('delete column: $index in table ${node.id}');

    final transaction = this.transaction;
    for (var i = 0; i < rowLength; i++) {
      final row = node.children[i];
      transaction.deleteNode(row.children[index]);
    }
    await apply(transaction);
  }

  /// Clear the content of the column at the given index.
  ///
  /// Before:
  /// Given column index: 0
  /// Row 1: | 0 | 1 | ← The content of these cells will be cleared
  /// Row 2: | 2 | 3 |
  ///
  /// Call this function with column index 0 will clear the first column of the table.
  ///
  /// After:
  /// Row 1: |   |   |
  /// Row 2: | 2 | 3 |
  Future<void> clearContentAtColumnIndex(Node node, int index) async {
    assert(node.type == SimpleTableBlockKeys.type);

    if (node.type != SimpleTableBlockKeys.type) {
      return;
    }

    if (index < 0 || index >= node.columnLength) {
      Log.warn('clear content in column: index out of range: $index');
      return;
    }

    Log.info('clear content in column: $index in table ${node.id}');

    final transaction = this.transaction;

    final row = node.children[index];
    for (var i = 0; i < row.children.length; i++) {
      final cell = row.children[i];
      transaction.insertNode(cell.path.next, simpleTableCellBlockNode());
      transaction.deleteNode(cell);
    }
    await apply(transaction);
  }

  /// Clear the content of the row at the given index.
  ///
  /// Before:
  /// Given row index: 1
  ///              ↓ The content of these cells will be cleared
  /// Row 1: | 0 | 1 |
  /// Row 2: | 2 | 3 |
  ///
  /// Call this function with row index 1 will clear the second row of the table.
  ///
  /// After:
  /// Row 1: | 0 |   |
  /// Row 2: | 2 |   |
  Future<void> clearContentAtRowIndex(Node node, int index) async {
    assert(node.type == SimpleTableBlockKeys.type);

    if (node.type != SimpleTableBlockKeys.type) {
      return;
    }

    if (index < 0 || index >= node.rowLength) {
      Log.warn('clear content in row: index out of range: $index');
      return;
    }

    Log.info('clear content in row: $index in table ${node.id}');

    final transaction = this.transaction;
    for (var i = 0; i < node.columnLength; i++) {
      final row = node.children[i];
      final cell = index >= row.children.length
          ? row.children.last
          : row.children[index];
      transaction.insertNode(cell.path.next, simpleTableCellBlockNode());
      transaction.deleteNode(cell);
    }
    await apply(transaction);
  }

  /// Toggle the enable header column of the table.
  Future<void> toggleEnableHeaderColumn(Node node, bool enable) async {
    assert(node.type == SimpleTableBlockKeys.type);

    if (node.type != SimpleTableBlockKeys.type) {
      return;
    }

    Log.info('toggle enable header column: $enable in table ${node.id}');

    final transaction = this.transaction;
    transaction.updateNode(node, {
      SimpleTableBlockKeys.enableHeaderColumn: enable,
    });
    await apply(transaction);
  }

  /// Toggle the enable header row of the table.
  Future<void> toggleEnableHeaderRow(Node node, bool enable) async {
    assert(node.type == SimpleTableBlockKeys.type);

    if (node.type != SimpleTableBlockKeys.type) {
      return;
    }

    Log.info('toggle enable header row: $enable in table ${node.id}');

    final transaction = this.transaction;
    transaction.updateNode(node, {
      SimpleTableBlockKeys.enableHeaderRow: enable,
    });
    await apply(transaction);
  }

  /// Update the column width of the table in memory.
  ///
  /// The deltaX is the change of the column width.
  Future<void> updateColumnWidthInMemory({
    required Node tableCellNode,
    required double deltaX,
  }) async {
    assert(tableCellNode.type == SimpleTableCellBlockKeys.type);

    if (tableCellNode.type != SimpleTableCellBlockKeys.type) {
      return;
    }

    // when dragging the table column, we need to update the column width in memory.
    // so that the table can render the column with the new width.
    // but don't need to persist to the database immediately.
    // only persist to the database when the drag is completed.
    final columnIndex = tableCellNode.columnIndex;
    final parentTableNode = tableCellNode.parentTableNode;
    if (parentTableNode == null) {
      Log.warn('parent table node is null');
      return;
    }

    final width = tableCellNode.columnWidth + deltaX;

    try {
      final columnWidths =
          parentTableNode.attributes[SimpleTableBlockKeys.columnWidths] ??
              SimpleTableColumnWidthMap();
      final newAttributes = {
        ...parentTableNode.attributes,
        SimpleTableBlockKeys.columnWidths: {
          ...columnWidths,
          columnIndex.toString(): width.clamp(
            SimpleTableConstants.minimumColumnWidth,
            double.infinity,
          ),
        },
      };

      parentTableNode.updateAttributes(newAttributes);
    } catch (e) {
      Log.warn('update column width in memory: $e');
    }
  }

  /// Update the column width of the table.
  Future<void> updateColumnWidth({
    required Node tableCellNode,
    required double width,
  }) async {
    assert(tableCellNode.type == SimpleTableCellBlockKeys.type);

    if (tableCellNode.type != SimpleTableCellBlockKeys.type) {
      return;
    }

    final cellPosition = tableCellNode.cellPosition;
    final rowIndex = cellPosition.$2;
    final parentTableNode = tableCellNode.parentTableNode;
    if (parentTableNode == null) {
      Log.warn('parent table node is null');
      return;
    }

    final width = tableCellNode.columnWidth;
    final transaction = this.transaction;
    transaction.updateNode(parentTableNode, {
      SimpleTableBlockKeys.columnWidths: {
        ...parentTableNode.attributes[SimpleTableBlockKeys.columnWidths],
        rowIndex.toString(): width.clamp(
          SimpleTableConstants.minimumColumnWidth,
          double.infinity,
        ),
      },
    });
    await apply(transaction);
  }

  /// Update the align of the column at the index where the table cell node is located.
  ///
  /// Before:
  /// Given table cell node:
  /// Row 1: | 0 | 1 |
  /// Row 2: |2  |3  | ← This column will be updated
  ///
  /// Call this function will update the align of the column where the table cell node is located.
  ///
  /// After:
  /// Row 1: | 0 | 1 |
  /// Row 2: | 2 | 3 | ← This column is updated, texts are aligned to the center
  Future<void> updateColumnAlign({
    required Node tableCellNode,
    required TableAlign align,
  }) async {
    assert(tableCellNode.type == SimpleTableCellBlockKeys.type);

    final parentTableNode = tableCellNode.parentTableNode;

    if (parentTableNode == null) {
      Log.warn('parent table node is null');
      return;
    }

    final transaction = this.transaction;
    final columnIndex = tableCellNode.columnIndex;
    final attributes = parentTableNode.attributes;
    try {
      final columnAligns = attributes[SimpleTableBlockKeys.columnAligns] ??
          SimpleTableColumnAlignMap();
      final newAttributes = {
        ...attributes,
        SimpleTableBlockKeys.columnAligns: {
          ...columnAligns,
          columnIndex.toString(): align.name,
        },
      };
      transaction.updateNode(parentTableNode, newAttributes);
    } catch (e) {
      Log.warn('update column align: $e');
    }
    await apply(transaction);
  }

  /// Update the align of the row at the index where the table cell node is located.
  ///
  /// Before:
  /// Given table cell node:
  ///              ↓ This row will be updated
  /// Row 1: | 0 |1  |
  /// Row 2: | 2 |3  |
  ///
  /// Call this function will update the align of the row where the table cell node is located.
  ///
  /// After:
  ///              ↓ This row is updated, texts are aligned to the center
  /// Row 1: | 0 | 1 |
  /// Row 2: | 2 | 3 |
  Future<void> updateRowAlign({
    required Node tableCellNode,
    required TableAlign align,
  }) async {
    assert(tableCellNode.type == SimpleTableCellBlockKeys.type);

    final parentTableNode = tableCellNode.parentTableNode;

    if (parentTableNode == null) {
      Log.warn('parent table node is null');
      return;
    }

    final transaction = this.transaction;
    final rowIndex = tableCellNode.rowIndex;
    final attributes = parentTableNode.attributes;
    try {
      final rowAligns = attributes[SimpleTableBlockKeys.rowAligns] ??
          SimpleTableRowAlignMap();
      final newAttributes = {
        ...attributes,
        SimpleTableBlockKeys.rowAligns: {
          ...rowAligns,
          rowIndex.toString(): align.name,
        },
      };
      transaction.updateNode(parentTableNode, newAttributes);
    } catch (e) {
      Log.warn('update row align: $e');
    }
    await apply(transaction);
  }

  /// Update the background color of the column at the index where the table cell node is located.
  Future<void> updateColumnBackgroundColor({
    required Node tableCellNode,
    required String color,
  }) async {
    assert(tableCellNode.type == SimpleTableCellBlockKeys.type);

    final parentTableNode = tableCellNode.parentTableNode;

    if (parentTableNode == null) {
      Log.warn('parent table node is null');
      return;
    }

    final columnIndex = tableCellNode.columnIndex;

    Log.info(
      'update column background color: $color at column $columnIndex in table ${parentTableNode.id}',
    );

    final transaction = this.transaction;
    final attributes = parentTableNode.attributes;
    try {
      final columnColors = attributes[SimpleTableBlockKeys.columnColors] ??
          SimpleTableColorMap();
      final newAttributes = {
        ...attributes,
        SimpleTableBlockKeys.columnColors: {
          ...columnColors,
          columnIndex.toString(): color,
        },
      };
      transaction.updateNode(parentTableNode, newAttributes);
    } catch (e) {
      Log.warn('update column background color: $e');
    }
    await apply(transaction);
  }

  /// Update the background color of the row at the index where the table cell node is located.
  Future<void> updateRowBackgroundColor({
    required Node tableCellNode,
    required String color,
  }) async {
    assert(tableCellNode.type == SimpleTableCellBlockKeys.type);

    final parentTableNode = tableCellNode.parentTableNode;

    if (parentTableNode == null) {
      Log.warn('parent table node is null');
      return;
    }

    final rowIndex = tableCellNode.rowIndex;

    Log.info(
      'update row background color: $color at row $rowIndex in table ${parentTableNode.id}',
    );

    final transaction = this.transaction;

    final attributes = parentTableNode.attributes;
    try {
      final rowColors =
          attributes[SimpleTableBlockKeys.rowColors] ?? SimpleTableColorMap();
      final newAttributes = {
        ...attributes,
        SimpleTableBlockKeys.rowColors: {
          ...rowColors,
          rowIndex.toString(): color,
        },
      };
      transaction.updateNode(parentTableNode, newAttributes);
    } catch (e) {
      Log.warn('update row background color: $e');
    }
    await apply(transaction);
  }
}
