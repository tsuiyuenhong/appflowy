class PluginDescription {
  const PluginDescription({
    required this.name,
    required this.author,
    required this.version,
    required this.timestamp,
    required this.oneLineDescription,
    required this.markdownDescription,
  });

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

  // static dateFormatter = DateFormat('MM/dd/yyyy');
  String get lastUpdated {
    // FIXME: use real timestamp
    return '2023-01-01';
  }
}
