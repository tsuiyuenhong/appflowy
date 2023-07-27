import 'package:appflowy/workspace/application/view/view_bloc.dart';
import 'package:appflowy/workspace/presentation/widgets/draggable_item/draggable_item.dart';
import 'package:appflowy_backend/log.dart';
import 'package:appflowy_backend/protobuf/flowy-folder2/view.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum DraggableHoverPosition {
  none,
  top,
  center,
  bottom,
}

class DraggableViewItem extends StatefulWidget {
  const DraggableViewItem({
    super.key,
    required this.view,
    required this.child,
  });

  final Widget child;
  final ViewPB view;

  @override
  State<DraggableViewItem> createState() => _DraggableViewItemState();
}

class _DraggableViewItemState extends State<DraggableViewItem> {
  DraggableHoverPosition position = DraggableHoverPosition.none;

  @override
  Widget build(BuildContext context) {
    // add top border if the draggable item is on the top of the list
    // highlight the draggable item if the draggable item is on the center
    // add bottom border if the draggable item is on the bottom of the list
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          height: 2,
          thickness: 2,
          color: position == DraggableHoverPosition.top
              ? Theme.of(context).colorScheme.secondary
              : Colors.transparent,
        ),
        Container(
          color: position == DraggableHoverPosition.center
              ? Theme.of(context).colorScheme.secondary
              : Colors.transparent,
          child: widget.child,
        ),
        Divider(
          height: 2,
          thickness: 2,
          color: position == DraggableHoverPosition.bottom
              ? Theme.of(context).colorScheme.secondary
              : Colors.transparent,
        ),
      ],
    );

    return DraggableItem<ViewPB>(
      data: widget.view,
      onWillAccept: (data) => true,
      onMove: (data) {
        if (!_shouldAccept(data.data)) {
          return;
        }

        final renderBox = context.findRenderObject() as RenderBox;
        final offset = renderBox.globalToLocal(data.offset);

        setState(() {
          position = _computeHoverPosition(offset);
          Log.debug('offset: $offset, position: $position');
        });
      },
      onLeave: (_) => setState(
        () => position = DraggableHoverPosition.none,
      ),
      onAccept: (data) {
        _move(data, widget.view);
        setState(
          () => position = DraggableHoverPosition.none,
        );
      },
      feedback: IntrinsicWidth(
        child: Opacity(
          opacity: 0.5,
          child: child,
        ),
      ),
      child: child,
    );
  }

  void _move(ViewPB from, ViewPB to) {
    if (position == DraggableHoverPosition.bottom) {
      context.read<ViewBloc>().add(
            ViewEvent.move(
              from,
              to.parentViewId,
              to.id,
            ),
          );
    } else if (position == DraggableHoverPosition.center) {
      context.read<ViewBloc>().add(
            ViewEvent.move(
              from,
              to.id,
              null,
            ),
          );
    }
  }

  DraggableHoverPosition _computeHoverPosition(Offset offset) {
    if (offset.dy < -5) {
      return DraggableHoverPosition.top;
    }
    if (offset.dy > 0) {
      return DraggableHoverPosition.bottom;
    }
    return DraggableHoverPosition.center;
  }

  bool _shouldAccept(ViewPB data) {
    if (data.id == widget.view.id) {
      return false;
    }

    if (data.containsView(widget.view)) {
      return false;
    }

    return true;
  }
}

extension on ViewPB {
  bool containsView(ViewPB view) {
    if (id == view.id) {
      return true;
    }

    return childViews.any((v) => v.containsView(view));
  }
}
