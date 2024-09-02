import 'dart:convert';

import 'package:appflowy/mobile/application/page_style/document_page_style_bloc.dart';
import 'package:appflowy/workspace/application/view/view_ext.dart';
import 'package:appflowy/workspace/application/view/view_listener.dart';
import 'package:appflowy/workspace/application/view/view_service.dart';
import 'package:appflowy_backend/log.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_immersive_cover_bloc.freezed.dart';

class DocumentImmersiveCoverBloc
    extends Bloc<DocumentImmersiveCoverEvent, DocumentImmersiveCoverState> {
  DocumentImmersiveCoverBloc({
    required this.view,
  })  : _viewListener = ViewListener(viewId: view.id),
        super(DocumentImmersiveCoverState.initial()) {
    on<DocumentImmersiveCoverEvent>(
      (event, emit) async {
        await event.when(
          initial: () async {
            latestView = view;

            add(
              DocumentImmersiveCoverEvent.update(
                view.cover,
                view.icon.value,
                view.name,
                view.coverOffset,
              ),
            );
            _viewListener?.start(
              onViewUpdated: (view) {
                latestView = view;

                add(
                  DocumentImmersiveCoverEvent.update(
                    view.cover,
                    view.icon.value,
                    view.name,
                    view.coverOffset,
                  ),
                );
              },
            );
          },
          update: (cover, icon, name, offset) {
            emit(
              state.copyWith(
                icon: icon,
                cover: cover ?? state.cover,
                name: name ?? state.name,
                offset: offset ?? state.offset,
              ),
            );
          },
          reposition: (offset) {
            // ignore: unawaited_futures
            _reposition(offset);
          },
        );
      },
    );
  }

  final ViewPB view;
  final ViewListener? _viewListener;

  // It's the latest view data, the view above is the initial view data.
  late ViewPB latestView;

  Future<void> _reposition(Offset offset) async {
    try {
      final current =
          latestView.extra.isNotEmpty ? jsonDecode(latestView.extra) : {};
      final Map<String, dynamic> cover = current[ViewExtKeys.coverKey] ?? {};
      if (cover.isEmpty) {
        return;
      }
      final extra = <String, dynamic>{
        ViewExtKeys.coverOffsetDxKey: offset.dx,
        ViewExtKeys.coverOffsetDyKey: offset.dy,
      };
      // merge the cover with the new offset
      final merged = mergeMaps(cover, extra);
      // merge the current view extra with the new cover
      current[ViewExtKeys.coverKey] = merged;

      await ViewBackendService.updateView(
        viewId: view.id,
        extra: jsonEncode(current),
      );
    } catch (e) {
      Log.error('Failed to reposition cover: $e');
    }
  }

  @override
  Future<void> close() {
    _viewListener?.stop();
    return super.close();
  }
}

@freezed
class DocumentImmersiveCoverEvent with _$DocumentImmersiveCoverEvent {
  const factory DocumentImmersiveCoverEvent.initial() = Initial;
  const factory DocumentImmersiveCoverEvent.update(
    PageStyleCover? cover,
    String? icon,
    String? name,
    Offset? offset,
  ) = Update;
  const factory DocumentImmersiveCoverEvent.reposition(Offset offset) =
      Reposition;
}

@freezed
class DocumentImmersiveCoverState with _$DocumentImmersiveCoverState {
  const factory DocumentImmersiveCoverState({
    @Default(null) String? icon,
    required PageStyleCover cover,
    @Default('') String name,
    @Default(null) Offset? offset,
  }) = _DocumentImmersiveCoverState;

  factory DocumentImmersiveCoverState.initial() => DocumentImmersiveCoverState(
        cover: PageStyleCover.none(),
      );
}
