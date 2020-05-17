import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_summary.dart';
import 'package:flutter/foundation.dart';

class SummaryScreenModel with ChangeNotifier
{
  final DateTime _date;

  List<ProcedureSummary> _summary = List();

  bool get isSummaryEmpty => _summary.isEmpty;
  int get summaryCount => _summary.length;

  double _workedHours = 0.0;
  double get workedHours => _workedHours;


  SummaryScreenModel(this._date) {
    loadSummary();
  }


  void loadSummary() async{
    _summary = await SQLiteDbProvider.db.getDaySummary(_date)..toList(growable: false);
    _summary.forEach((f) {
      _workedHours += f.timeSpent;
    });
    notifyListeners();
  }


  ProcedureSummary getProcedureSummaryAt(int index) {
    return _summary.elementAt(index);
  }
}