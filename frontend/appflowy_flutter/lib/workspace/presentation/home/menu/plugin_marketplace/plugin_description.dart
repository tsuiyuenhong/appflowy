import 'package:intl/intl.dart';

class PluginDescription {
  const PluginDescription({
    required this.id,
    required this.name,
    required this.author,
    required this.version,
    required this.timestamp,
    required this.oneLineDescription,
    required this.markdownDescription,
  });

  final String id;

  // name of the plugin
  final String name;

  // author of the plugin
  final String author;

  // timestamp of the last update, millseconds since epoch
  final int timestamp;

  // version of the plugin
  final String version;

  // one line description of the plugin
  final String oneLineDescription;

  // markdown description of the plugin
  final String markdownDescription;

  static DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  String get lastUpdated => dateFormatter.format(
        DateTime.fromMillisecondsSinceEpoch(timestamp),
      );
}
