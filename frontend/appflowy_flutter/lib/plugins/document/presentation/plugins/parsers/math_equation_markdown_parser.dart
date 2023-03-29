import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';

class MathEquationMarkdownParser extends MarkdownParser {
  static final RegExp _mathExp = RegExp(r'\$\$.*?\$\$|\$.*?\$');
  static final RegExp _contentExp = RegExp(r'(?<=\$\$).*?(?=\$\$)');

  @override
  Node? transform(String markdown) {
    if (!_mathExp.hasMatch(markdown)) {
      return null;
    }
    final match = _mathExp.firstMatch(markdown);
    if (match == null) {
      return null;
    }
    final text = match.group(0);
    if (text == null || text.length != markdown.length) {
      return null;
    }
    final content = _contentExp.firstMatch(text)?.group(0);
    if (content == null) {
      return null;
    }
    return Node(
      type: kMathEquationType,
      attributes: {
        kMathEquationAttr: content.trim(),
      },
    );
  }
}
