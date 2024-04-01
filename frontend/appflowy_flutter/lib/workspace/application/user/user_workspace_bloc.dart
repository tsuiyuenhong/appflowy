import 'package:appflowy/core/config/kv.dart';
import 'package:appflowy/core/config/kv_keys.dart';
import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/shared/feature_flags.dart';
import 'package:appflowy/startup/startup.dart';
import 'package:appflowy/user/application/user_listener.dart';
import 'package:appflowy/user/application/user_service.dart';
import 'package:appflowy_backend/log.dart';
import 'package:appflowy_backend/protobuf/flowy-error/code.pbenum.dart';
import 'package:appflowy_backend/protobuf/flowy-error/errors.pb.dart';
import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';
import 'package:appflowy_result/appflowy_result.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:protobuf/protobuf.dart';

part 'user_workspace_bloc.freezed.dart';

class UserWorkspaceBloc extends Bloc<UserWorkspaceEvent, UserWorkspaceState> {
  UserWorkspaceBloc({
    required this.userProfile,
  })  : _userService = UserBackendService(userId: userProfile.id),
        _listener = UserListener(userProfile: userProfile),
        super(UserWorkspaceState.initial()) {
    on<UserWorkspaceEvent>(
      (event, emit) async {
        await event.when(
          initial: () async {
            _listener
              ..didUpdateUserWorkspaces = (workspaces) {
                add(UserWorkspaceEvent.updateWorkspaces(workspaces));
              }
              ..start();

            final result = await _fetchWorkspaces();
            final isCollabWorkspaceOn =
                userProfile.authenticator != AuthenticatorPB.Local &&
                    FeatureFlag.collaborativeWorkspace.isOn;
            final currentWorkspace = result?.$1;
            if (currentWorkspace != null && result?.$3 == true) {
              await _userService.openWorkspace(currentWorkspace.workspaceId);
            }
            emit(
              state.copyWith(
                currentWorkspace: currentWorkspace,
                workspaces: result?.$2 ?? [],
                isCollabWorkspaceOn: isCollabWorkspaceOn,
                actionResult: null,
              ),
            );
          },
          fetchWorkspaces: () async {
            final result = await _fetchWorkspaces();
            if (result != null) {
              emit(
                state.copyWith(
                  currentWorkspace: result.$1,
                  workspaces: result.$2,
                ),
              );
            } else {
              emit(
                state.copyWith(
                  actionResult: UserWorkspaceActionResult(
                    actionType: UserWorkspaceActionType.none,
                    result: FlowyResult.failure(
                      FlowyError(
                        code: ErrorCode.Internal,
                        msg: LocaleKeys.workspace_fetchWorkspacesFailed.tr(),
                      ),
                    ),
                  ),
                ),
              );
            }
          },
          createWorkspace: (name) async {
            final result = await _userService.createUserWorkspace(name);
            final workspaces = result.fold(
              (s) => [...state.workspaces, s],
              (e) => state.workspaces,
            );
            emit(
              state.copyWith(
                workspaces: workspaces,
                actionResult: UserWorkspaceActionResult(
                  actionType: UserWorkspaceActionType.create,
                  result: result,
                ),
              ),
            );
            // open the created workspace by default
            result.onSuccess((s) {
              add(OpenWorkspace(s.workspaceId));
            });
          },
          deleteWorkspace: (workspaceId) async {
            if (state.workspaces.length <= 1) {
              // do not allow to delete the last workspace, otherwise the user
              // cannot do create workspace again
              final result = FlowyResult.failure(
                FlowyError(
                  code: ErrorCode.Internal,
                  msg: LocaleKeys.workspace_cannotDeleteTheOnlyWorkspace.tr(),
                ),
              );
              return emit(
                state.copyWith(
                  actionResult: UserWorkspaceActionResult(
                    actionType: UserWorkspaceActionType.delete,
                    result: result,
                  ),
                ),
              );
            }

            final result = await _userService.deleteWorkspaceById(workspaceId);
            final workspaces = result.fold(
              // remove the deleted workspace from the list instead of fetching
              // the workspaces again
              (s) => state.workspaces
                  .where((e) => e.workspaceId != workspaceId)
                  .toList(),
              (e) => state.workspaces,
            );
            result.onSuccess((_) {
              // if the current workspace is deleted, open the first workspace
              if (state.currentWorkspace?.workspaceId == workspaceId) {
                add(OpenWorkspace(workspaces.first.workspaceId));
              }
            });
            emit(
              state.copyWith(
                workspaces: workspaces,
                actionResult: UserWorkspaceActionResult(
                  actionType: UserWorkspaceActionType.delete,
                  result: result,
                ),
              ),
            );
          },
          openWorkspace: (workspaceId) async {
            final result = await _userService.openWorkspace(workspaceId);
            final currentWorkspace = result.fold(
              (s) => state.workspaces.firstWhereOrNull(
                (e) => e.workspaceId == workspaceId,
              ),
              (e) => state.currentWorkspace,
            );
            result.onSuccess((_) async {
              await getIt<KeyValueStorage>().set(
                KVKeys.lastOpenedWorkspaceId,
                workspaceId,
              );
            });
            emit(
              state.copyWith(
                currentWorkspace: currentWorkspace,
                actionResult: UserWorkspaceActionResult(
                  actionType: UserWorkspaceActionType.open,
                  result: result,
                ),
              ),
            );
          },
          renameWorkspace: (workspaceId, name) async {
            final result =
                await _userService.renameWorkspace(workspaceId, name);
            final workspaces = result.fold(
              (s) => state.workspaces.map(
                (e) {
                  if (e.workspaceId == workspaceId) {
                    e.freeze();
                    return e.rebuild((p0) {
                      p0.name = name;
                    });
                  }
                  return e;
                },
              ).toList(),
              (f) => state.workspaces,
            );
            final currentWorkspace = workspaces.firstWhere(
              (e) => e.workspaceId == state.currentWorkspace?.workspaceId,
            );
            emit(
              state.copyWith(
                workspaces: workspaces,
                currentWorkspace: currentWorkspace,
                actionResult: UserWorkspaceActionResult(
                  actionType: UserWorkspaceActionType.rename,
                  result: result,
                ),
              ),
            );
          },
          updateWorkspaceIcon: (workspaceId, icon) async {
            final result = await _userService.updateWorkspaceIcon(
              workspaceId,
              icon,
            );
            final workspaces = result.fold(
              (s) => state.workspaces.map(
                (e) {
                  if (e.workspaceId == workspaceId) {
                    e.freeze();
                    return e.rebuild((p0) {
                      p0.icon = icon;
                    });
                  }
                  return e;
                },
              ).toList(),
              (f) => state.workspaces,
            );
            final currentWorkspace = workspaces.firstWhere(
              (e) => e.workspaceId == state.currentWorkspace?.workspaceId,
            );
            emit(
              state.copyWith(
                workspaces: workspaces,
                currentWorkspace: currentWorkspace,
                actionResult: UserWorkspaceActionResult(
                  actionType: UserWorkspaceActionType.updateIcon,
                  result: result,
                ),
              ),
            );
          },
          leaveWorkspace: (workspaceId) async {
            final result = await _userService.leaveWorkspace(workspaceId);
            final workspaces = result.fold(
              (s) => state.workspaces
                  .where((e) => e.workspaceId != workspaceId)
                  .toList(),
              (e) => state.workspaces,
            );
            result.onSuccess((_) {
              // if leaving the current workspace, open the first workspace
              if (state.currentWorkspace?.workspaceId == workspaceId) {
                add(OpenWorkspace(workspaces.first.workspaceId));
              }
            });
            emit(
              state.copyWith(
                workspaces: workspaces,
                actionResult: UserWorkspaceActionResult(
                  actionType: UserWorkspaceActionType.leave,
                  result: result,
                ),
              ),
            );
          },
          updateWorkspaces: (workspaces) async {
            if (!const DeepCollectionEquality()
                .equals(workspaces.items, state.workspaces)) {
              emit(
                state.copyWith(
                  workspaces: workspaces.items,
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Future<void> close() {
    _listener.stop();
    return super.close();
  }

  final UserProfilePB userProfile;
  final UserBackendService _userService;
  final UserListener _listener;

  Future<
      (
        UserWorkspacePB currentWorkspace,
        List<UserWorkspacePB> workspaces,
        bool shouldOpenWorkspace,
      )?> _fetchWorkspaces() async {
    try {
      final lastOpenedWorkspaceId = await getIt<KeyValueStorage>().get(
        KVKeys.lastOpenedWorkspaceId,
      );
      final currentWorkspace =
          await _userService.getCurrentWorkspace().getOrThrow();
      final workspaces = await _userService.getWorkspaces().getOrThrow();
      UserWorkspacePB currentWorkspaceInList =
          workspaces.firstWhere((e) => e.workspaceId == currentWorkspace.id);
      if (lastOpenedWorkspaceId != null) {
        final lastOpenedWorkspace = workspaces
            .firstWhereOrNull((e) => e.workspaceId == lastOpenedWorkspaceId);
        if (lastOpenedWorkspace != null) {
          currentWorkspaceInList = lastOpenedWorkspace;
        }
      }
      return (
        currentWorkspaceInList,
        workspaces,
        lastOpenedWorkspaceId != currentWorkspace.id
      );
    } catch (e) {
      Log.error('fetch workspace error: $e');
      return null;
    }
  }
}

@freezed
class UserWorkspaceEvent with _$UserWorkspaceEvent {
  const factory UserWorkspaceEvent.initial() = Initial;
  const factory UserWorkspaceEvent.fetchWorkspaces() = FetchWorkspaces;
  const factory UserWorkspaceEvent.createWorkspace(String name) =
      CreateWorkspace;
  const factory UserWorkspaceEvent.deleteWorkspace(String workspaceId) =
      DeleteWorkspace;
  const factory UserWorkspaceEvent.openWorkspace(String workspaceId) =
      OpenWorkspace;
  const factory UserWorkspaceEvent.renameWorkspace(
    String workspaceId,
    String name,
  ) = _RenameWorkspace;
  const factory UserWorkspaceEvent.updateWorkspaceIcon(
    String workspaceId,
    String icon,
  ) = _UpdateWorkspaceIcon;
  const factory UserWorkspaceEvent.leaveWorkspace(String workspaceId) =
      LeaveWorkspace;
  const factory UserWorkspaceEvent.updateWorkspaces(
    RepeatedUserWorkspacePB workspaces,
  ) = UpdateWorkspaces;
}

enum UserWorkspaceActionType {
  none,
  create,
  delete,
  open,
  rename,
  updateIcon,
  fetchWorkspaces,
  leave;
}

class UserWorkspaceActionResult {
  const UserWorkspaceActionResult({
    required this.actionType,
    required this.result,
  });

  final UserWorkspaceActionType actionType;
  final FlowyResult<void, FlowyError> result;
}

@freezed
class UserWorkspaceState with _$UserWorkspaceState {
  const UserWorkspaceState._();

  const factory UserWorkspaceState({
    @Default(null) UserWorkspacePB? currentWorkspace,
    @Default([]) List<UserWorkspacePB> workspaces,
    @Default(null) UserWorkspaceActionResult? actionResult,
    @Default(false) bool isCollabWorkspaceOn,
  }) = _UserWorkspaceState;

  factory UserWorkspaceState.initial() => const UserWorkspaceState();

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserWorkspaceState &&
        other.currentWorkspace == currentWorkspace &&
        other.workspaces == workspaces &&
        identical(other.actionResult, actionResult);
  }
}
