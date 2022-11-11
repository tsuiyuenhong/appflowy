import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('document_html_decoder.dart', () {
    test('heading', () {
      const input = '''<h1>Welcome to AppFlowy!</h1>
<h2>Welcome to AppFlowy!</h2>
<h3>Welcome to AppFlowy!</h3>''';
      final document = DocumentHTMLDecoder().convert(input);
      for (var i = 1; i <= 3; i++) {
        final node = document.nodeAtPath([i - 1])!;
        expect(node is TextNode, true);
        expect(node.subtype, BuiltInAttributeKey.heading);
        expect(node.attributes[BuiltInAttributeKey.heading], 'h$i');
      }
    });

    test('Single line', () {
      const input =
          '''<p><i>Welcome to </i><strong><a href="https://appflowy.io">AppFlowy</a></strong>!</p>''';
      final document = DocumentHTMLDecoder().convert(input);
      final node = document.nodeAtPath([0])!;
      expect(document.root.children.length, 2);
      expect(node is TextNode, true);
      expect(
        (node as TextNode).delta,
        Delta()
          ..insert('Welcome to ', attributes: {
            BuiltInAttributeKey.italic: true,
          })
          ..insert('AppFlowy', attributes: {
            BuiltInAttributeKey.bold: true,
            BuiltInAttributeKey.href: 'https://appflowy.io',
          })
          ..insert('!'),
      );
    });

    test('blockquote', () {
      const input = '''<p><blockquote>Welcome to AppFlowy!</blockquote></p>''';
      final document = DocumentHTMLDecoder().convert(input);
      final node = document.nodeAtPath([0])!;
      expect(document.root.children.length, 2);
      expect(node is TextNode, true);
      expect(node.subtype, BuiltInAttributeKey.quote);
    });

    test('unorder list', () {
      const input = '''<ul><li>Coffee</li><li>Tea</li><li>Milk</li></ul>''';
      final document = DocumentHTMLDecoder().convert(input);
      expect(document.root.children.length, 4);
      for (var i = 1; i <= 3; i++) {
        final node = document.nodeAtPath([i - 1])!;
        expect(node is TextNode, true);
        expect(node.subtype, BuiltInAttributeKey.bulletedList);
      }
    });
  });
}
