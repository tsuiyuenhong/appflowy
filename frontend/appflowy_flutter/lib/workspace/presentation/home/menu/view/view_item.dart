import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/workspace/application/tabs/tabs_bloc.dart';
import 'package:appflowy/workspace/application/view/view_bloc.dart';
import 'package:appflowy/workspace/application/view/view_ext.dart';
import 'package:appflowy/workspace/presentation/home/menu/view/draggable_view_item.dart';
import 'package:appflowy/workspace/presentation/home/menu/view/view_action_type.dart';
import 'package:appflowy/workspace/presentation/home/menu/view/view_add_button.dart';
import 'package:appflowy/workspace/presentation/home/menu/view/view_more_action_button.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra/image.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:appflowy_backend/protobuf/flowy-folder2/view.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewItem extends StatelessWidget {
  const ViewItem({
    super.key,
    required this.view,
    required this.level,
    this.leftPadding = 10,
    required this.isExpanded,
    required this.onSelected,
  });

  final ViewPB view;

  // indicate the level of the view item
  // used to calculate the left padding
  final int level;

  // the left padding of the view item for each level
  // the left padding of the each level = level * leftPadding
  final double leftPadding;

  final bool isExpanded;
  final void Function(ViewPB) onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ViewBloc(view: view)..add(const ViewEvent.initial()),
      child: BlocBuilder<ViewBloc, ViewState>(
        builder: (context, state) {
          return InnerViewItem(
            view: view,
            childViews: state.childViews,
            level: level,
            leftPadding: leftPadding,
            showActions: state.isEditing,
            isExpanded: state.isExpanded,
            onSelected: onSelected,
          );
        },
      ),
    );
  }
}

class InnerViewItem extends StatefulWidget {
  const InnerViewItem({
    super.key,
    required this.view,
    this.childViews = const [],
    this.isDraggable = true,
    this.isExpanded = true,
    required this.level,
    this.leftPadding = 10,
    required this.showActions,
    required this.onSelected,
  });

  final ViewPB view;
  final List<ViewPB> childViews;

  final bool isDraggable;
  final bool isExpanded;

  final int level;
  final double leftPadding;

  final bool showActions;
  final void Function(ViewPB) onSelected;

  @override
  State<InnerViewItem> createState() => _InnerViewItemState();
}

class _InnerViewItemState extends State<InnerViewItem> {
  bool onHover = false;

  @override
  Widget build(BuildContext context) {
    final children = [
      // expand icon
      _buildExpandedIcon(),
      // icon
      SizedBox(
        width: 16,
        height: 16,
        child: widget.view.icon(),
      ),
      const HSpace(5),
      // title
      Expanded(
        child: FlowyText.regular(
          widget.view.name,
          overflow: TextOverflow.ellipsis,
        ),
      )
    ];

    // hover action
    if (widget.showActions || onHover) {
      // ··· more action button
      children.add(_buildViewMoreActionButton(context));
      // + button
      children.add(_buildViewAddButton(context));
    }

    Widget child = MouseRegion(
      onEnter: (_) => setState(() => onHover = true),
      onExit: (_) => setState(() => onHover = false),
      child: GestureDetector(
        onTap: () => widget.onSelected(widget.view),
        child: SizedBox(
          height: 26,
          child: Padding(
            padding: EdgeInsets.only(left: widget.level * widget.leftPadding),
            child: Row(
              children: children,
            ),
          ),
        ),
      ),
    );

    // if the view is expanded and has child views, render its child views
    if (widget.isExpanded && widget.childViews.isNotEmpty) {
      final children = widget.childViews.map((childView) {
        return ViewItem(
          key: ValueKey(childView.id),
          view: childView,
          level: widget.level + 1,
          isExpanded: true,
          onSelected: widget.onSelected,
        );
      }).toList();
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          ...children,
        ],
      );
    }

    // wrap the child with DraggableItem if isDraggable is true
    if (widget.isDraggable) {
      child = DraggableViewItem(
        view: widget.view,
        child: child,
      );
    }

    return child;
  }

  // > button
  Widget _buildExpandedIcon() {
    final name =
        widget.isExpanded ? 'home/drop_down_show' : 'home/drop_down_hide';
    return GestureDetector(
      child: FlowySvg(name: name),
      onTap: () => context
          .read<ViewBloc>()
          .add(ViewEvent.setIsExpanded(!widget.isExpanded)),
    );
  }

  // + button
  Widget _buildViewAddButton(BuildContext context) {
    return Tooltip(
      message: LocaleKeys.menuAppHeader_addPageTooltip.tr(),
      child: ViewAddButton(
        parentViewId: widget.view.id,
        onEditing: (value) =>
            context.read<ViewBloc>().add(ViewEvent.setIsEditing(value)),
        onSelected: (pluginBuilder, name, initialDataBytes, openAfterCreated) {
          context.read<ViewBloc>().add(
                ViewEvent.createView(
                  name ?? LocaleKeys.menuAppHeader_defaultNewPageName.tr(),
                  pluginBuilder.layoutType!,
                  openAfterCreated: openAfterCreated,
                ),
              );
          context.read<ViewBloc>().add(
                const ViewEvent.setIsExpanded(true),
              );
        },
      ),
    );
  }

  // ··· more action button
  Widget _buildViewMoreActionButton(BuildContext context) {
    return Tooltip(
      message: LocaleKeys.menuAppHeader_moreButtonToolTip.tr(),
      child: ViewMoreActionButton(
        onEditing: (value) =>
            context.read<ViewBloc>().add(ViewEvent.setIsEditing(value)),
        onAction: (action) {
          switch (action) {
            case ViewMoreActionType.rename:
              NavigatorTextFieldDialog(
                title: LocaleKeys.disclosureAction_rename.tr(),
                autoSelectAllText: true,
                value: widget.view.name,
                confirm: (newValue) {
                  context.read<ViewBloc>().add(ViewEvent.rename(newValue));
                },
              ).show(context);
              break;
            case ViewMoreActionType.delete:
              context.read<ViewBloc>().add(const ViewEvent.delete());
              break;
            case ViewMoreActionType.duplicate:
              context.read<ViewBloc>().add(const ViewEvent.duplicate());
              break;
            case ViewMoreActionType.openInNewTab:
              context.read<TabsBloc>().add(
                    TabsEvent.openTab(
                      plugin: widget.view.plugin(),
                      view: widget.view,
                    ),
                  );
              break;
            default:
              throw UnsupportedError('$action is not supported');
          }
        },
      ),
    );
  }
}
