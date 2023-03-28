import 'package:appflowy/workspace/presentation/home/menu/plugin_marketplace/plugin_description.dart';
import 'package:appflowy/workspace/presentation/home/menu/plugin_marketplace/plugin_marketplace.dart';
import 'package:flutter/material.dart';

class SettingPluginMarketPlaceView extends StatelessWidget {
  const SettingPluginMarketPlaceView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FIXME: remove this test code later.
    final List<PluginDescription> pluginDesciptions = [];
    for (var i = 0; i < 20; i++) {
      pluginDesciptions.add(PluginDescription(
        name: 'PLUGIN $i',
        author: 'LUCAS XU',
        version: '$i.0.0',
        timestamp: 1679994126,
        oneLineDescription:
            'IMPROVE THE PERFORMANCE OF THE APP, HELLO WORLD, HELLO WORLD',
        markdownDescription: '''
# IMPROVE THE PERFORMANCE OF THE APP.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
* HELLO WORLD.
''',
      ));
    }
    return PluginMarketPlace(
      pluginDesciptions: pluginDesciptions,
    );
  }
}
