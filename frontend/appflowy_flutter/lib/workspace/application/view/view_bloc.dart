import 'package:appflowy/workspace/application/view/view_listener.dart';
import 'package:appflowy/workspace/application/view/view_service.dart';
import 'package:dartz/dartz.dart';
import 'package:appflowy_backend/protobuf/flowy-folder2/view.pb.dart';
import 'package:appflowy_backend/protobuf/flowy-error/errors.pb.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'view_bloc.freezed.dart';

class ViewBloc extends Bloc<ViewEvent, ViewState> {
  final ViewBackendService viewBackendSvc;
  final ViewListener listener;
  final ViewPB view;

  ViewBloc({
    required this.view,
  })  : viewBackendSvc = ViewBackendService(),
        listener = ViewListener(viewId: view.id),
        super(ViewState.init(view)) {
    on<ViewEvent>((event, emit) async {
      await event.map(
        initial: (e) async {
          listener.start(
            onViewUpdated: (result) {
              add(ViewEvent.viewDidUpdate(left(result)));
            },
          );
          await _loadViews(emit);
        },
        setIsEditing: (e) {
          emit(state.copyWith(isEditing: e.isEditing));
        },
        setIsExpanded: (e) {
          emit(state.copyWith(isExpanded: e.isExpanded));
        },
        viewDidUpdate: (e) {
          e.result.fold(
            (view) => emit(
              state.copyWith(
                view: view,
                childViews: view.childViews,
                successOrFailure: left(unit),
              ),
            ),
            (error) => emit(
              state.copyWith(successOrFailure: right(error)),
            ),
          );
        },
        rename: (e) async {
          final result = await ViewBackendService.updateView(
            viewId: view.id,
            name: e.newName,
          );
          emit(
            result.fold(
              (l) => state.copyWith(successOrFailure: left(unit)),
              (error) => state.copyWith(successOrFailure: right(error)),
            ),
          );
        },
        delete: (e) async {
          final result = await ViewBackendService.delete(viewId: view.id);
          emit(
            result.fold(
              (l) => state.copyWith(successOrFailure: left(unit)),
              (error) => state.copyWith(successOrFailure: right(error)),
            ),
          );
        },
        duplicate: (e) async {
          final result = await ViewBackendService.duplicate(view: view);
          emit(
            result.fold(
              (l) => state.copyWith(successOrFailure: left(unit)),
              (error) => state.copyWith(successOrFailure: right(error)),
            ),
          );
        },
        move: (value) async {
          final result = await ViewBackendService.moveViewV2(
            viewId: value.from.id,
            newParentId: value.newParentId,
            prevViewId: value.prevId,
          );
          emit(
            result.fold(
              (l) => state.copyWith(successOrFailure: left(unit)),
              (error) => state.copyWith(successOrFailure: right(error)),
            ),
          );
        },
        createView: (e) async {
          final result = await ViewBackendService.createView(
            parentViewId: view.id,
            name: e.name,
            desc: '',
            layoutType: e.layoutType,
            initialDataBytes: null,
            ext: {},
            openAfterCreate: e.openAfterCreated,
          );
          emit(
            result.fold(
              (l) => state.copyWith(successOrFailure: left(unit)),
              (error) => state.copyWith(successOrFailure: right(error)),
            ),
          );
        },
      );
    });
  }

  @override
  Future<void> close() async {
    await listener.stop();
    return super.close();
  }

  Future<void> _loadViews(Emitter<ViewState> emit) async {
    final viewsOrFailed =
        await ViewBackendService.getChildViews(viewId: state.view.id);
    viewsOrFailed.fold(
      (childViews) => emit(state.copyWith(childViews: childViews)),
      (error) => emit(state.copyWith(successOrFailure: right(error))),
    );
  }
}

@freezed
class ViewEvent with _$ViewEvent {
  const factory ViewEvent.initial() = Initial;
  const factory ViewEvent.setIsEditing(bool isEditing) = SetEditing;
  const factory ViewEvent.setIsExpanded(bool isExpanded) = SetIsExpanded;
  const factory ViewEvent.rename(String newName) = Rename;
  const factory ViewEvent.delete() = Delete;
  const factory ViewEvent.duplicate() = Duplicate;
  const factory ViewEvent.move(
    ViewPB from,
    String newParentId,
    String? prevId,
  ) = Move;
  const factory ViewEvent.createView(
    String name,
    ViewLayoutPB layoutType, {
    /// open the view after created
    @Default(true) bool openAfterCreated,
  }) = CreateView;
  const factory ViewEvent.viewDidUpdate(Either<ViewPB, FlowyError> result) =
      ViewDidUpdate;
}

@freezed
class ViewState with _$ViewState {
  const factory ViewState({
    required ViewPB view,
    required List<ViewPB> childViews,
    required bool isEditing,
    required bool isExpanded,
    required Either<Unit, FlowyError> successOrFailure,
  }) = _ViewState;

  factory ViewState.init(ViewPB view) => ViewState(
        view: view,
        childViews: view.childViews,
        isExpanded: false,
        isEditing: false,
        successOrFailure: left(unit),
      );
}
