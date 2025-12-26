import 'package:flutter/cupertino.dart';

class FocusProvider with ChangeNotifier {
  FocusNode? _messageFocusNode;

  FocusNode get messageFocusNode {
    // Always create a fresh FocusNode if null or disposed
    if (_messageFocusNode == null) {
      _messageFocusNode = FocusNode();
    }
    return _messageFocusNode!;
  }

  // Call this before navigating away
  void resetFocusNode() {
    _messageFocusNode?.dispose();
    _messageFocusNode = FocusNode();
    notifyListeners();
  }

  void unfocus() {
    _messageFocusNode?.unfocus();
  }

  @override
  void dispose() {
    _messageFocusNode?.dispose();
    super.dispose();
  }
}
