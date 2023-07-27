import 'package:flutter/material.dart';

enum ViewMoreActionType {
  delete,
  addToFavorites, // not supported yet.
  duplicate,
  copyLink, // not supported yet.
  rename,
  moveTo, // not supported yet.
  openInNewTab,
}

extension ViewMoreActionTypeExtension on ViewMoreActionType {
  // FIXME(Lucas.Xu): i18n
  String get name {
    switch (this) {
      case ViewMoreActionType.delete:
        return 'Delete';
      case ViewMoreActionType.addToFavorites:
        return 'Add to Favorites';
      case ViewMoreActionType.duplicate:
        return 'Duplicate';
      case ViewMoreActionType.copyLink:
        return 'Copy link';
      case ViewMoreActionType.rename:
        return 'Rename';
      case ViewMoreActionType.moveTo:
        return 'Move to';
      case ViewMoreActionType.openInNewTab:
        return 'Open in new tab';
    }
  }

  Widget icon(Color iconColor) {
    // FIXME(Lucas.Xu): icon
    switch (this) {
      case ViewMoreActionType.delete:
        return const Icon(Icons.delete);
      case ViewMoreActionType.addToFavorites:
        return const Icon(Icons.favorite);
      case ViewMoreActionType.duplicate:
        return const Icon(Icons.copy);
      case ViewMoreActionType.copyLink:
        return const Icon(Icons.copy);
      case ViewMoreActionType.rename:
        return const Icon(Icons.edit_note);
      case ViewMoreActionType.moveTo:
        return const Icon(Icons.move_to_inbox);
      case ViewMoreActionType.openInNewTab:
        return const Icon(Icons.open_in_new);
    }
  }
}
