import 'package:appflowy/workspace/presentation/home/menu/plugin_marketplace/builtin_plugin_descriptions.dart';
import 'package:appflowy/workspace/presentation/home/menu/plugin_marketplace/plugin_description.dart';
import 'package:appflowy/workspace/presentation/home/menu/plugin_marketplace/plugin_marketplace.dart';
import 'package:flutter/material.dart';

class SettingPluginMarketPlaceView extends StatelessWidget {
  const SettingPluginMarketPlaceView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<PluginDescription> pluginDesciptions = [
      ...builtInPluginDesriptions,
    ];
    return PluginMarketPlace(
      pluginDesciptions: pluginDesciptions,
    );
  }
}
