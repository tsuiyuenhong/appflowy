import 'package:appflowy/plugins/document/editor_styles.dart';
import 'package:appflowy/workspace/presentation/home/menu/plugin_marketplace/plugin_description.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flowy_infra/size.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

class PluginMarketPlace extends StatefulWidget {
  const PluginMarketPlace({
    super.key,
    required this.pluginDesciptions,
  });

  final List<PluginDescription> pluginDesciptions;

  @override
  State<PluginMarketPlace> createState() => _PluginMarketPlaceState();
}

class _PluginMarketPlaceState extends State<PluginMarketPlace> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.8,
      children: <Widget>[
        for (final description in widget.pluginDesciptions)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PluginDescriptionCard(description: description),
          ),
      ],
    );
  }
}

class PluginDescriptionCard extends StatelessWidget {
  const PluginDescriptionCard({
    super.key,
    required this.description,
  });

  final PluginDescription description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: Corners.s6Border,
      ),
      child: FlowyButton(
        margin: const EdgeInsets.all(8.0),
        useIntrinsicWidth: true,
        onTap: () {
          final document = markdownToDocument(description.markdownDescription);
          final editorState = EditorState(document: document);
          final dialog = FlowyDialog(
            child: AppFlowyEditor(
              editorState: editorState,
              editable: false,
              themeData: theme.copyWith(
                extensions: [
                  ...theme.extensions.values,
                  customEditorTheme(context)
                      .copyWith(backgroundColor: Colors.transparent),
                  ...customPluginTheme(context),
                ],
              ),
            ),
          );
          showDialog(
            context: context,
            builder: (context) => dialog,
          );
        },
        text: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              description.name,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(height: 5),
            Text(
              'By ${description.author}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Last Updated in ${description.lastUpdated}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            Flexible(
              child: Text(
                description.oneLineDescription,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            )
          ],
        ),
      ),
    );
  }
}
