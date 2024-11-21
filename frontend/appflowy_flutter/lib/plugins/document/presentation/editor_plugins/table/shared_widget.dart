import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/table/simple_table_block_component.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/table/simple_table_constants.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/table/simple_table_more_action.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/table/table_operations.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SimpleTableReorderButton extends StatelessWidget {
  const SimpleTableReorderButton({
    super.key,
    required this.isShowingMenu,
    required this.type,
  });

  final ValueNotifier<bool> isShowingMenu;
  final SimpleTableMoreActionType type;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isShowingMenu,
      builder: (context, isShowingMenu, child) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            decoration: BoxDecoration(
              color: isShowingMenu
                  ? context.simpleTableMoreActionHoverColor
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: context.simpleTableMoreActionBorderColor,
              ),
            ),
            width: 16,
            height: 16,
            child: FlowySvg(
              type.reorderIconSvg,
              color: isShowingMenu ? Colors.white : null,
            ),
          ),
        );
      },
    );
  }
}

class SimpleTableAddRowHoverButton extends StatelessWidget {
  const SimpleTableAddRowHoverButton({
    super.key,
    required this.editorState,
    required this.node,
  });

  final EditorState editorState;
  final Node node;

  @override
  Widget build(BuildContext context) {
    assert(node.type == SimpleTableBlockKeys.type);

    if (node.type != SimpleTableBlockKeys.type) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder(
      valueListenable: context.read<SimpleTableContext>().isHoveringOnTable,
      builder: (context, value, child) {
        return value
            ? Positioned(
                bottom: 0,
                left: SimpleTableConstants.tableLeftPadding -
                    SimpleTableConstants.cellBorderWidth,
                right: SimpleTableConstants.addRowButtonRightPadding,
                child: SimpleTableAddRowButton(
                  onTap: () => editorState.addRowInTable(node),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}

class SimpleTableAddRowButton extends StatelessWidget {
  const SimpleTableAddRowButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FlowyTooltip(
      message: 'Click to add a new row',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            height: SimpleTableConstants.addRowButtonHeight,
            margin: const EdgeInsets.symmetric(
              vertical: SimpleTableConstants.addRowButtonPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                SimpleTableConstants.addRowButtonRadius,
              ),
              color: context.simpleTableMoreActionBackgroundColor,
            ),
            child: const FlowySvg(
              FlowySvgs.add_s,
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleTableAddColumnHoverButton extends StatelessWidget {
  const SimpleTableAddColumnHoverButton({
    super.key,
    required this.editorState,
    required this.node,
  });

  final EditorState editorState;
  final Node node;

  @override
  Widget build(BuildContext context) {
    assert(node.type == SimpleTableBlockKeys.type);

    if (node.type != SimpleTableBlockKeys.type) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder(
      valueListenable: context.read<SimpleTableContext>().isHoveringOnTable,
      builder: (context, value, child) {
        return value
            ? Positioned(
                top: SimpleTableConstants.tableTopPadding -
                    SimpleTableConstants.cellBorderWidth,
                bottom: SimpleTableConstants.addColumnButtonBottomPadding,
                right: 0,
                child: SimpleTableAddColumnButton(
                  onTap: () {
                    editorState.addColumnInTable(node);
                  },
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}

class SimpleTableAddColumnButton extends StatelessWidget {
  const SimpleTableAddColumnButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FlowyTooltip(
      message: 'Click to add a new column',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: SimpleTableConstants.addColumnButtonWidth,
            margin: const EdgeInsets.symmetric(
              horizontal: SimpleTableConstants.addColumnButtonPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                SimpleTableConstants.addColumnButtonRadius,
              ),
              color: context.simpleTableMoreActionBackgroundColor,
            ),
            child: const FlowySvg(
              FlowySvgs.add_s,
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleTableAddColumnAndRowHoverButton extends StatelessWidget {
  const SimpleTableAddColumnAndRowHoverButton({
    super.key,
    required this.editorState,
    required this.node,
  });

  final EditorState editorState;
  final Node node;

  @override
  Widget build(BuildContext context) {
    assert(node.type == SimpleTableBlockKeys.type);

    if (node.type != SimpleTableBlockKeys.type) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder(
      valueListenable: context.read<SimpleTableContext>().isHoveringOnTable,
      builder: (context, value, child) {
        return value
            ? Positioned(
                bottom: SimpleTableConstants.addRowButtonPadding,
                right: SimpleTableConstants.addColumnButtonPadding,
                child: SimpleTableAddColumnAndRowButton(
                  onTap: () => editorState.addColumnAndRowInTable(node),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}

class SimpleTableAddColumnAndRowButton extends StatelessWidget {
  const SimpleTableAddColumnAndRowButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FlowyTooltip(
      message: 'Click to add a new column and row',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: SimpleTableConstants.addColumnAndRowButtonWidth,
            height: SimpleTableConstants.addColumnAndRowButtonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                SimpleTableConstants.addColumnAndRowButtonCornerRadius,
              ),
              color: context.simpleTableMoreActionBackgroundColor,
            ),
            child: const FlowySvg(
              FlowySvgs.add_s,
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleTableRowDivider extends StatelessWidget {
  const SimpleTableRowDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const VerticalDivider(
      color: SimpleTableConstants.borderColor,
      width: 1.0,
    );
  }
}

class SimpleTableColumnDivider extends StatelessWidget {
  const SimpleTableColumnDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: SimpleTableConstants.borderColor,
      height: 1.0,
    );
  }
}

class SimpleTableAlignMenu extends StatelessWidget {
  const SimpleTableAlignMenu({
    super.key,
    required this.type,
    this.popoverMutex,
  });

  final SimpleTableMoreActionType type;
  final PopoverMutex? popoverMutex;

  @override
  Widget build(BuildContext context) {
    final controller = PopoverController();
    return AppFlowyPopover(
      asBarrier: true,
      controller: controller,
      child: SimpleTableBasicButton(
        leftIconSvg: TableAlign.left.leftIconSvg,
        text: 'Align',
        onTap: () {
          controller.show();
        },
      ),
      popupBuilder: (context) {
        return Container(
          width: 100,
          color: Colors.red,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAlignButton(context, TableAlign.left),
              _buildAlignButton(context, TableAlign.center),
              _buildAlignButton(context, TableAlign.right),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlignButton(BuildContext context, TableAlign align) {
    return SimpleTableBasicButton(
      leftIconSvg: align.leftIconSvg,
      text: align.name,
      onTap: () {},
    );
  }
}

class SimpleTableBasicButton extends StatelessWidget {
  const SimpleTableBasicButton({
    super.key,
    required this.text,
    required this.onTap,
    this.leftIconSvg,
    this.leftIconBuilder,
    this.rightIcon,
  });

  final FlowySvgData? leftIconSvg;
  final String text;
  final VoidCallback onTap;
  final Widget Function(bool onHover)? leftIconBuilder;
  final Widget? rightIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SimpleTableConstants.moreActionHeight,
      padding: SimpleTableConstants.moreActionPadding,
      child: FlowyIconTextButton(
        margin: SimpleTableConstants.moreActionHorizontalMargin,
        leftIconBuilder: _buildLeftIcon,
        iconPadding: 10.0,
        textBuilder: (onHover) => FlowyText.regular(
          text,
          fontSize: 14.0,
          figmaLineHeight: 18.0,
        ),
        onTap: onTap,
        rightIconBuilder: (onHover) => rightIcon ?? const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildLeftIcon(bool onHover) {
    if (leftIconBuilder != null) {
      return leftIconBuilder!(onHover);
    }
    return leftIconSvg != null
        ? FlowySvg(leftIconSvg!)
        : const SizedBox.shrink();
  }
}