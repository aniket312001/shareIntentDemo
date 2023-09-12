import 'dart:developer';

import 'package:flutter/foundation.dart';

class LoaderPercentageChange with ChangeNotifier {
  dynamic _percentage = 0;

  dynamic get getPercentage => _percentage;

  void changePercentage(dynamic value) {
    _percentage = value;
    notifyListeners();
  }
}
