import 'package:flutter/foundation.dart';


class ActionFormModel with ChangeNotifier {
  String _procedureName;
  String get procedureName => _procedureName;
  set procedureName(String name) {
    _procedureName = name?.trim();
    notifyListeners();
  }


  String _procedureNameErrorText;
  String get procedureNameErrorText => _procedureNameErrorText;
  set procedureNameErrorText(String msg) {
    _procedureNameErrorText = msg.trim();
    notifyListeners();
  }


  ActionFormModel([String procedureName]) {
    this.procedureName = procedureName;
  }
}