import 'package:appflowy/workspace/presentation/home/menu/plugin_marketplace/plugin_description.dart';

List<PluginDescription> builtInPluginDesriptions = [
  dividerPluginDescription,
  mathEquationPluginDescription,
  codeBlockPluginDescription,
  boardPluginDescription,
  gridPluginDescription,
  calloutPluginDescription,
  askAIToWritePluginDescription,
  coverPluginDescription,
  smartEditPluginDescription,
];

const dividerPluginDescription = PluginDescription(
  id: 'divider',
  name: 'Divider',
  author: 'AppFlowy',
  version: '1.0.0',
  timestamp: 1669852800000,
  oneLineDescription: 'Divider',
  markdownDescription: '''
# Description
To create a divider, use three underscores (___) on a line or insert it via slash menu.

The rendered output of it looks identical:

---
''',
);

const mathEquationPluginDescription = PluginDescription(
  id: 'math_equation',
  name: 'Math Equation',
  author: 'AppFlowy',
  version: '1.0.0',
  timestamp: 1669852800000,
  oneLineDescription: 'Math Equation',
  markdownDescription: r'''
# Description
To create a math equation, insert it via slash menu.

This \`$$ x = {-b \pm \sqrt{b^2-4ac} \over 2a} $$\`

The rendered output of it looks identical:

$$ x = {-b \pm \sqrt{b^2-4ac} \over 2a} $$
''',
);

const codeBlockPluginDescription = PluginDescription(
  id: 'text/code_block',
  name: 'Code Block',
  author: 'AppFlowy, abichinger',
  version: '1.0.0',
  timestamp: 1669852800000,
  oneLineDescription: 'Code Block',
  documentJsonDescription: r'''
{"document":{"type":"editor","children":[{"type":"cover"},{"type":"text","attributes":{"subtype":"heading","heading":"h1"},"delta":[{"insert":"Description"}]},{"type":"text","delta":[{"insert":"code block"}]},{"type":"text"},{"type":"text","attributes":{"subtype":"code_block","theme":"vs","language":"dart"},"delta":[{"insert":"\nfinal String welcome = 'AppFlowy';\n"}]},{"type":"text"}]}}
''',
);

const boardPluginDescription = PluginDescription(
  id: 'board',
  name: 'Board',
  author: 'AppFlowy',
  version: '1.0.0',
  timestamp: 1669852800000,
  oneLineDescription: 'Board',
  markdownDescription: '''
# Description
To create a divider, use three underscores (___) on a line or insert it via slash menu.

The rendered output of it looks identical:

---
''',
);

const gridPluginDescription = PluginDescription(
  id: 'grid',
  name: 'Grid',
  author: 'AppFlowy',
  version: '1.0.0',
  timestamp: 1669852800000,
  oneLineDescription: 'Grid',
  markdownDescription: '''
# Description
To create a divider, use three underscores (___) on a line or insert it via slash menu.

The rendered output of it looks identical:

---
''',
);

const calloutPluginDescription = PluginDescription(
  id: 'callout',
  name: 'Callout',
  author: 'abichinger',
  version: '1.0.0',
  timestamp: 1669852800000,
  oneLineDescription: 'Callout',
  documentJsonDescription: r'''
{"document":{"type":"editor","children":[{"type":"cover"},{"type":"text","delta":[{"insert":"Here's an example for "},{"insert":"Callout","attributes":{"bold":true}},{"insert":".","attributes":{"bold":false}}]},{"type":"text"},{"type":"callout","children":[{"type":"text","delta":[{"insert":"Hello "},{"insert":"AppFlowy","attributes":{"bold":true,"underline":true,"italic":true}},{"insert":"!"}]},{"type":"text","attributes":{"subtype":null,"bulleted-list":null}}]},{"type":"text"}]}}''',
);

const askAIToWritePluginDescription = PluginDescription(
  id: 'auto_completion_input',
  name: 'Ask AI to write',
  author: 'AppFlowy',
  version: '1.0.0',
  timestamp: 1669852800000,
  oneLineDescription: 'Ask AI to write',
  markdownDescription: '''
# Description
To create a divider, use three underscores (___) on a line or insert it via slash menu.

The rendered output of it looks identical:

---
''',
);

const coverPluginDescription = PluginDescription(
  id: 'cover',
  name: 'Cover',
  author: 'Muhammad Rizwan',
  version: '1.0.0',
  timestamp: 1669852800000,
  oneLineDescription: 'Cover',
  documentJsonDescription: r'''
{"document":{"type":"editor","children":[{"type":"cover","attributes":{"cover_selection_type":"CoverSelectionType.asset","cover_selection":"assets/images/app_flowy_abstract_cover_1.jpg","selected_icon":"😄"}},{"type":"text","delta":[{"insert":"Here's a cover plugin example."}]}]}}''',
);

const smartEditPluginDescription = PluginDescription(
  id: 'smart_edit',
  name: 'Smart Edit',
  author: 'AppFlowy',
  version: '1.0.0',
  timestamp: 1669852800000,
  oneLineDescription: 'Smart Edit',
  markdownDescription: '''
# Description
To create a divider, use three underscores (___) on a line or insert it via slash menu.

The rendered output of it looks identical:

---
''',
);
