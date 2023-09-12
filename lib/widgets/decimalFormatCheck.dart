import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Only allow digits and a single decimal point
    if (newValue.text == '.' || newValue.text.isEmpty) {
      return newValue;
    } else if (newValue.text.contains('.') &&
        oldValue.text != '.' &&
        !oldValue.text.contains('.')) {
      // If a decimal point already exists, and it's not the first character, keep it
      return newValue;
    } else if (newValue.text.contains('.') &&
        newValue.text.indexOf('.') != newValue.text.lastIndexOf('.')) {
      // If there's more than one decimal point, remove the extra one
      return oldValue;
    } else {
      return newValue;
    }
  }
}
