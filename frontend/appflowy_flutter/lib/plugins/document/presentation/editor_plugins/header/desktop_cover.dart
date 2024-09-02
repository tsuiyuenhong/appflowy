import 'dart:io';

import 'package:appflowy/mobile/application/page_style/document_page_style_bloc.dart';
import 'package:appflowy/plugins/document/application/prelude.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/cover/document_immersive_cover_bloc.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy/shared/appflowy_network_image.dart';
import 'package:appflowy/shared/flowy_gradient_colors.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flowy_infra/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:string_validator/string_validator.dart';

/// This is a transitional component that can be removed once the desktop
///  supports immersive widgets, allowing for the exclusive use of the DocumentImmersiveCover component.
class DesktopCover extends StatefulWidget {
  const DesktopCover({
    super.key,
    required this.view,
    required this.editorState,
    required this.node,
    required this.coverType,
    this.coverDetails,
  });

  final ViewPB view;
  final Node node;
  final EditorState editorState;
  final CoverType coverType;
  final String? coverDetails;

  @override
  State<DesktopCover> createState() => _DesktopCoverState();
}

class _DesktopCoverState extends State<DesktopCover> {
  CoverType get coverType => CoverType.fromString(
        widget.node.attributes[DocumentHeaderBlockKeys.coverType],
      );
  String? get coverDetails =>
      widget.node.attributes[DocumentHeaderBlockKeys.coverDetails];

  @override
  Widget build(BuildContext context) {
    if (widget.view.extra.isEmpty) {
      return _buildCoverImageV1();
    }

    return _buildCoverImageV2();
  }

  // version > 0.5.5
  Widget _buildCoverImageV2() {
    return BlocProvider(
      create: (context) => DocumentImmersiveCoverBloc(view: widget.view)
        ..add(const DocumentImmersiveCoverEvent.initial()),
      child:
          BlocBuilder<DocumentImmersiveCoverBloc, DocumentImmersiveCoverState>(
        builder: (context, state) {
          final cover = state.cover;
          final type = state.cover.type;
          final offset = state.offset;
          const height = kCoverHeight;

          if (type == PageStyleCoverImageType.customImage ||
              type == PageStyleCoverImageType.unsplashImage) {
            final userProfilePB =
                context.read<DocumentBloc>().state.userProfilePB;
            return SizedBox(
              height: height,
              width: double.infinity,
              child: _Repositionable(
                initialOffset: offset,
                onPositionChanged: (offset) {
                  context.read<DocumentImmersiveCoverBloc>().add(
                        DocumentImmersiveCoverEvent.reposition(offset),
                      );
                },
                child: FlowyNetworkImage(
                  url: cover.value,
                  userProfilePB: userProfilePB,
                  fit: BoxFit.fill,
                ),
              ),
            );
          }

          if (type == PageStyleCoverImageType.builtInImage) {
            return SizedBox(
              height: height,
              width: double.infinity,
              child: Image.asset(
                PageStyleCoverImageType.builtInImagePath(cover.value),
                fit: BoxFit.cover,
              ),
            );
          }

          if (type == PageStyleCoverImageType.pureColor) {
            // try to parse the color from the tint id,
            //  if it fails, try to parse the color as a hex string
            final color = FlowyTint.fromId(cover.value)?.color(context) ??
                cover.value.tryToColor();
            return Container(
              height: height,
              width: double.infinity,
              color: color,
            );
          }

          if (type == PageStyleCoverImageType.gradientColor) {
            return Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: FlowyGradientColor.fromId(cover.value).linear,
              ),
            );
          }

          if (type == PageStyleCoverImageType.localImage) {
            return SizedBox(
              height: height,
              width: double.infinity,
              child: Image.file(
                File(cover.value),
                fit: BoxFit.cover,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // version <= 0.5.5
  Widget _buildCoverImageV1() {
    final detail = coverDetails;
    if (detail == null) {
      return const SizedBox.shrink();
    }
    switch (widget.coverType) {
      case CoverType.file:
        if (isURL(detail)) {
          final userProfilePB =
              context.read<DocumentBloc>().state.userProfilePB;
          return FlowyNetworkImage(
            url: detail,
            userProfilePB: userProfilePB,
            errorWidgetBuilder: (context, url, error) =>
                const SizedBox.shrink(),
          );
        }
        final imageFile = File(detail);
        if (!imageFile.existsSync()) {
          return const SizedBox.shrink();
        }
        return Image.file(
          imageFile,
          fit: BoxFit.cover,
        );
      case CoverType.asset:
        return Image.asset(
          PageStyleCoverImageType.builtInImagePath(detail),
          fit: BoxFit.cover,
        );
      case CoverType.color:
        final color = widget.coverDetails?.tryToColor() ?? Colors.white;
        return Container(color: color);
      case CoverType.none:
        return const SizedBox.shrink();
    }
  }
}

class _Repositionable extends StatefulWidget {
  const _Repositionable({
    this.onPositionChanged,
    this.initialOffset,
    required this.child,
  });

  final Offset? initialOffset;
  final Widget child;
  final void Function(Offset)? onPositionChanged;

  @override
  State<_Repositionable> createState() => _RepositionableState();
}

class _RepositionableState extends State<_Repositionable> {
  late Offset offset = widget.initialOffset ?? Offset.zero;
  Size childSize = Size.zero;
  Size containerSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        containerSize = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              final newOffset = offset + details.delta;
              // ensure the offset is within the bounds
              offset = _limitOffset(newOffset);
            });
          },
          onPanEnd: (_) => widget.onPositionChanged?.call(offset),
          child: ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Transform.translate(
                offset: offset,
                child: _MeasureSize(
                  onChange: (size) {
                    setState(() {
                      childSize = size;
                    });
                  },
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _limitOffset(Offset newOffset) {
    final maxX = (childSize.width - containerSize.width).abs() / 2;
    final maxY = (childSize.height - containerSize.height).abs() / 2;
    return Offset(
      newOffset.dx.clamp(-maxX, maxX),
      newOffset.dy.clamp(-maxY, maxY),
    );
  }
}

class _MeasureSize extends StatefulWidget {
  const _MeasureSize({
    required this.onChange,
    required this.child,
  });

  final Function(Size) onChange;
  final Widget child;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      if (size != null) {
        widget.onChange(size);
      }
    });
    return widget.child;
  }
}
