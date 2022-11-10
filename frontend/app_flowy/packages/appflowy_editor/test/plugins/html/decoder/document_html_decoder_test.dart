import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('document_html_decoder.dart', () {
    test('heading', () {
      const input = '''<ul dir="auto">
<li><a href="https://appflowy.gitbook.io/docs/essential-documentation/install-appflowy/installation-methods/mac-windows-linux-packages" rel="nofollow">Windows/Mac/Linux</a></li>
<li><a href="https://appflowy.gitbook.io/docs/essential-documentation/install-appflowy/installation-methods/installing-with-docker" rel="nofollow">Docker</a></li>
<li><a href="https://appflowy.gitbook.io/docs/essential-documentation/install-appflowy/installation-methods/from-source" rel="nofollow">Source</a></li>
</ul>''';
      final result = DocumentHTMLDecoder().convert(input);
      print(result.root.children.length);
      print(documentToMarkdown(result));
    });
  });
}
