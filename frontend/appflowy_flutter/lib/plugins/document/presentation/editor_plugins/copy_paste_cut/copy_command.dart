import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

CommandShortcutEvent copyCommand = CommandShortcutEvent(
  key: 'copy',
  command: 'ctrl+c',
  macOSCommand: 'meta+c',
  handler: _handler,
);

CommandShortcutEventHandler _handler = (editorState) {
  return KeyEventResult.handled;
};
