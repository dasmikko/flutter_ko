import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:knocky/models/slateDocument.dart';

class BBCodeHandler implements bbob.NodeVisitor {
  SlateDocument document = SlateDocument(object: 'document', nodes: List());
  StringBuffer _leafContentBuffer = StringBuffer();

  SlateNode _lastElement = null;
  List<SlateLeafMark> _leafMarks = List();

  SlateObject parse(String text) {
    print(text);

    var ast = bbob.parse(text);
    print(ast);

    for (final node in ast) {
      node.accept(this);
    }

    // New leaf is appearing, add old leaf to node
    SlateNode textLeafNode = SlateNode(object: 'text', leaves: [
      SlateLeaf(
          text: _leafContentBuffer.toString(),
          marks: _leafMarks,
          object: 'leaf')
    ]);

    // Add node
    _lastElement.nodes.add(textLeafNode);
    _leafContentBuffer = StringBuffer();
    document.nodes.add(_lastElement);

    return SlateObject(object: 'value', document: document);
  }

  void visitText(bbob.Text text) {
    if (_lastElement == null) {
      _lastElement =
          SlateNode(object: 'block', type: 'paragraph', nodes: List());
    }

    if (text.textContent == '\n') {
      // New leaf is appearing, add old leaf to node
      SlateNode textLeafNode = SlateNode(object: 'text', leaves: [
        SlateLeaf(
            text: _leafContentBuffer.toString(),
            marks: _leafMarks,
            object: 'leaf'),
      ]);

      // Reset leaf marks
      _leafMarks = List();

      // Add node
      _lastElement.nodes.add(textLeafNode);
      _leafContentBuffer = StringBuffer();

      document.nodes.add(_lastElement);

      // Paragraph ended, to reset last element
      _lastElement = null;
    } else {
      _leafContentBuffer.write(text.textContent);
    }
  }

  bool visitElementBefore(bbob.Element element) {
    if (_leafContentBuffer.isNotEmpty) {
      // New leaf is appearing, add old leaf to node
      SlateNode textNode = SlateNode(object: 'text', leaves: [
        SlateLeaf(
            text: _leafContentBuffer.toString(),
            marks: _leafMarks,
            object: 'leaf')
      ]);

      // Reset leaf marks
      _leafMarks = List();

      _lastElement.nodes.add(textNode);
      _leafContentBuffer = StringBuffer();
    }


    if (element.tag == 'b') {
      _leafMarks.add(SlateLeafMark(object: 'mark', type: 'bold'));
    }
    if (element.tag == 'i') {
      _leafMarks.add(SlateLeafMark(object: 'mark', type: 'italic'));
    }
    if (element.tag == 'u') {
      _leafMarks.add(SlateLeafMark(object: 'mark', type: 'underline'));
    }
    if (element.tag == 'code') {
      _leafMarks.add(SlateLeafMark(object: 'mark', type: 'code'));
    }
    if (element.tag == 'spoiler') {
      _leafMarks.add(SlateLeafMark(object: 'mark', type: 'spoiler'));
    }

    return true;
  }

  void visitElementAfter(bbob.Element element) {
    // Tag is done, add leaf
    SlateNode textNode = SlateNode(object: 'text', leaves: [
      SlateLeaf(
          text: _leafContentBuffer.toString(),
          marks: _leafMarks,
          object: 'leaf')
    ]);

    // Reset leaf marks
    _leafMarks = List();

    _lastElement.nodes.add(textNode);
    _leafContentBuffer = StringBuffer();
  }
}
