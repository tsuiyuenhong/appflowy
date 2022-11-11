class HTMLTag {
  static const h1 = 'h1';
  static const h2 = 'h2';
  static const h3 = 'h3';

  static const blockQuote = 'blockquote';
  static const orderedList = 'ol';
  static const unorderedList = 'ul';
  static const list = 'li';

  static const paragraph = 'p';
  static const image = 'img';
  static const div = 'div';

  static const anchor = 'a';
  static const italic = 'i';
  static const bold = 'b';
  static const underline = 'u';
  static const del = 'del';
  static const strong = 'strong';
  static const span = 'span';
  static const code = 'code';

  static bool isTopLevel(String tag) {
    return tag == h1 ||
        tag == h2 ||
        tag == h3 ||
        tag == paragraph ||
        tag == div ||
        tag == blockQuote;
  }

  static List<String> inlineTags = [
    anchor,
    span,
    code,
    strong,
    underline,
    italic,
    del,
  ];
}
