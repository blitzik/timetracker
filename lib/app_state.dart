import 'package:flutter/foundation.dart';

class AppState with ChangeNotifier{

  DateTime _date;
  DateTime get date => _date;
  set date(DateTime date) {
    _date = date;
  }

  AppState(this._date);
}