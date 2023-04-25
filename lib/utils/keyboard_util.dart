import 'package:flutter/cupertino.dart';

class KeyboardUtil {
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
