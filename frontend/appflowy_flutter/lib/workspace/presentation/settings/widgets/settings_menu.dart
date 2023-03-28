import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/workspace/application/settings/settings_dialog_bloc.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/settings_menu_element.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({
    Key? key,
    required this.changeSelectedPage,
    required this.currentPage,
  }) : super(key: key);

  final Function changeSelectedPage;
  final SettingsPage currentPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: SettingsPage.values
          .map(
            (page) => [
              SettingsMenuElement(
                page: page,
                selectedPage: currentPage,
                label: page.name,
                icon: page.icon,
                changeSelectedPage: changeSelectedPage,
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          )
          .expand((element) => element)
          .toList(growable: false),
    );
  }
}

extension on SettingsPage {
  String get name {
    switch (this) {
      case SettingsPage.appearance:
        return LocaleKeys.settings_menu_appearance.tr();
      case SettingsPage.language:
        return LocaleKeys.settings_menu_language.tr();
      case SettingsPage.files:
        return LocaleKeys.settings_menu_files.tr();
      case SettingsPage.user:
        return LocaleKeys.settings_menu_user.tr();
      case SettingsPage.pluginMarketplace:
        return 'Plugin Marketplace';
    }
  }

  IconData get icon {
    switch (this) {
      case SettingsPage.appearance:
        return Icons.brightness_4;
      case SettingsPage.language:
        return Icons.translate;
      case SettingsPage.files:
        return Icons.file_present_outlined;
      case SettingsPage.user:
        return Icons.account_box_outlined;
      case SettingsPage.pluginMarketplace:
        return Icons.store;
    }
  }
}
