import 'dart:developer';

import 'package:flutter/foundation.dart';

class LanguageChange with ChangeNotifier {
  String _selectedLanguage = "en";

  String get getSelectedLanguage => _selectedLanguage;

  void changeAppLanguage(String value) {
    log("new lang ${value} ");
    _selectedLanguage = value;
    notifyListeners();
  }
}
