import 'package:app/extensions/datetime_extension.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_summary.dart';
import 'package:flutter/foundation.dart';


enum SummaryType {
  day, week
}


class SummaryScreenModel with ChangeNotifier {
  DateTime _date;
  DateTime get date => _date;

  List<ProcedureSummary> _summary = List();

  bool get isSummaryEmpty => _summary.isEmpty;
  int get summaryCount => _summary.length;

  double _workedHours = 0.0;
  double get workedHours => _workedHours;

  SummaryType currentType;


  SummaryScreenModel(this._date) {
    currentType = SummaryType.day;
    loadSummary(currentType);
  }


  void loadSummary(SummaryType type) async{
    List<ProcedureSummary> summary;
    if (type == SummaryType.day) {
      summary = await SQLiteDbProvider.db.getDaySummary(
        date.year,
        date.month,
        date.day
      );
    } else {
      summary = await SQLiteDbProvider.db.getWeekSummary(
        date.year,
        date.getWeek()
      );
    }
    _workedHours = 0;
    _summary = summary.toList(growable: false);
    _summary.forEach((f) {
      _workedHours += f.timeSpent;
    });
    notifyListeners();
  }


  void toggleType() {
    if (currentType == SummaryType.day) {
      currentType = SummaryType.week;
    } else {
      currentType = SummaryType.day;
    }
    loadSummary(currentType);
  }


  ProcedureSummary getProcedureSummaryAt(int index) {
    return _summary.elementAt(index);
  }
}