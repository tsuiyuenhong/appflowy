import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/workspace/application/sidebar/space/space_bloc.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/space/space_icon_popup.dart';
import 'package:appflowy_popover/appflowy_popover.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flowy_infra_ui/style_widget/decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateSpacePopup extends StatefulWidget {
  const CreateSpacePopup({super.key});

  @override
  State<CreateSpacePopup> createState() => _CreateSpacePopupState();
}

class _CreateSpacePopupState extends State<CreateSpacePopup> {
  String spaceName = '';
  String spaceIcon = '';
  String spaceIconColor = '';
  SpacePermission spacePermission = SpacePermission.publicToAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlowyText(
            LocaleKeys.space_createNewSpace.tr(),
            fontSize: 18.0,
          ),
          const VSpace(4.0),
          FlowyText.regular(
            LocaleKeys.space_createSpaceDescription.tr(),
            fontSize: 14.0,
            color: Theme.of(context).hintColor,
          ),
          const VSpace(16.0),
          SizedBox.square(
            dimension: 56,
            child: SpaceIconPopup(
              onIconChanged: (icon, iconColor) {
                spaceIcon = icon;
                spaceIconColor = iconColor;
              },
            ),
          ),
          const VSpace(8.0),
          _SpaceNameTextField(onChanged: (value) => spaceName = value),
          const VSpace(16.0),
          _SpacePermissionSwitch(
            onPermissionChanged: (value) => spacePermission = value,
          ),
          const VSpace(16.0),
          _CancelOrCreateButton(
            onCancel: () => Navigator.of(context).pop(),
            onCreate: () {
              if (spaceName.isEmpty) {
                // todo: show error
                return;
              }

              context.read<SpaceBloc>().add(
                    SpaceEvent.create(
                      name: spaceName,
                      icon: spaceIcon,
                      iconColor: spaceIconColor,
                      permission: spacePermission,
                    ),
                  );

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _SpaceNameTextField extends StatelessWidget {
  const _SpaceNameTextField({required this.onChanged});

  final void Function(String name) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowyText.regular(
          LocaleKeys.space_spaceName.tr(),
          fontSize: 14.0,
          color: Theme.of(context).hintColor,
        ),
        const VSpace(6.0),
        FlowyTextField(
          hintText: 'Untitled space',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SpacePermissionSwitch extends StatefulWidget {
  const _SpacePermissionSwitch({required this.onPermissionChanged});

  final void Function(SpacePermission permission) onPermissionChanged;

  @override
  State<_SpacePermissionSwitch> createState() => _SpacePermissionSwitchState();
}

class _SpacePermissionSwitchState extends State<_SpacePermissionSwitch> {
  SpacePermission spacePermission = SpacePermission.publicToAll;
  final popoverController = PopoverController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowyText.regular(
          LocaleKeys.space_permission.tr(),
          fontSize: 14.0,
          color: Theme.of(context).hintColor,
        ),
        const VSpace(6.0),
        AppFlowyPopover(
          controller: popoverController,
          direction: PopoverDirection.bottomWithCenterAligned,
          constraints: const BoxConstraints(maxWidth: 500),
          offset: const Offset(0, 4),
          margin: EdgeInsets.zero,
          decoration: FlowyDecoration.decoration(
            Theme.of(context).cardColor,
            Theme.of(context).colorScheme.shadow,
            borderRadius: 10,
          ),
          popupBuilder: (_) => _buildPermissionButtons(),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0x1E14171B)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _SpacePermissionButton(
              permission: spacePermission,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionButtons() {
    return SizedBox(
      width: 452,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SpacePermissionButton(
            permission: SpacePermission.publicToAll,
            onTap: () => _onPermissionChanged(SpacePermission.publicToAll),
          ),
          _SpacePermissionButton(
            permission: SpacePermission.private,
            onTap: () => _onPermissionChanged(SpacePermission.private),
          ),
        ],
      ),
    );
  }

  void _onPermissionChanged(SpacePermission permission) {
    widget.onPermissionChanged(permission);

    setState(() {
      spacePermission = permission;
    });

    popoverController.close();
  }
}

class _SpacePermissionButton extends StatelessWidget {
  const _SpacePermissionButton({required this.permission, this.onTap});

  final SpacePermission permission;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (title, desc, icon) = switch (permission) {
      SpacePermission.publicToAll => (
          LocaleKeys.space_publicPermission.tr(),
          LocaleKeys.space_publicPermissionDescription.tr(),
          FlowySvgs.space_permission_public_s
        ),
      SpacePermission.private => (
          LocaleKeys.space_privatePermission.tr(),
          LocaleKeys.space_privatePermissionDescription.tr(),
          FlowySvgs.space_permission_private_s
        ),
    };

    return FlowyButton(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      radius: BorderRadius.circular(10),
      iconPadding: 16.0,
      leftIcon: FlowySvg(icon),
      rightIcon: const FlowySvg(FlowySvgs.space_permission_dropdown_s),
      text: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowyText.regular(title),
          const VSpace(4.0),
          FlowyText.regular(
            desc,
            fontSize: 12.0,
            color: Theme.of(context).hintColor,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _CancelOrCreateButton extends StatelessWidget {
  const _CancelOrCreateButton({required this.onCancel, required this.onCreate});

  final VoidCallback onCancel;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DecoratedBox(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0x1E14171B)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: FlowyButton(
            useIntrinsicWidth: true,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
            text: const FlowyText.regular('Cancel'),
            onTap: onCancel,
          ),
        ),
        const HSpace(12.0),
        DecoratedBox(
          decoration: ShapeDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: FlowyButton(
            useIntrinsicWidth: true,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
            text: FlowyText.regular(
              LocaleKeys.button_create.tr(),
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onTap: onCreate,
          ),
        ),
      ],
    );
  }
}
