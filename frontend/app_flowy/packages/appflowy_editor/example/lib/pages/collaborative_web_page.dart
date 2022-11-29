import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CollaborativeWebPage extends StatefulWidget {
  const CollaborativeWebPage({
    super.key,
    required this.token,
  });

  final String token;

  @override
  State<CollaborativeWebPage> createState() => _CollaborativeWebPageState();
}

class _CollaborativeWebPageState extends State<CollaborativeWebPage> {
  var loading = true;
  var editorState = EditorState.empty();

  @override
  void initState() {
    super.initState();

    _sync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return AppFlowyEditor(
        editorState: editorState,
        shortcutEvents: [
          ShortcutEvent(
            key: 'sync document with firebase cloud',
            command: 'meta+s',
            handler: _saveEventHandler,
          )
        ],
      );
    }
  }

  void _sync() async {
    if (widget.token.isNotEmpty) {
      FirebaseDatabase.instance.ref('docs/${widget.token}').onValue.listen(
        (event) {
          if (event.snapshot.value is String) {
            editorState = EditorState(
              document: Document.fromJson(
                json.decode(event.snapshot.value as String),
              ),
            );
          }
          setState(() => loading = false);
        },
      );
    } else {
      setState(() => loading = false);
    }
  }

  KeyEventResult _saveEventHandler(
      EditorState editorState, RawKeyEvent? event) {
    if (widget.token.isEmpty) {
      return KeyEventResult.ignored;
    }
    final json = jsonEncode(editorState.document.toJson());
    FirebaseDatabase.instance
        .ref('docs/${widget.token}')
        .set(json)
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Synced In FireBase Cloud')),
      );
    });
    return KeyEventResult.handled;
  }
}
