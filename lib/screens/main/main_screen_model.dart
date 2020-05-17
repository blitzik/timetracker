import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app/app_state.dart';


class MainScreenModel with ChangeNotifier {
  AppState _appState;

  DateTime get _date => _appState.date;

  List<ProcedureRecord> _procedureRecords = List();
  int get procedureRecordsCount => _procedureRecords.length;
  bool get isProcedureRecordsEmpty => _procedureRecords.isEmpty;

  ProcedureRecord get lastProcedureRecord => _procedureRecords.isEmpty ? null : _procedureRecords.first;
  int get lastProcedureRecordIndex => _procedureRecords.length - 1;

  double _workedHours = 0;
  double get workedHours => _workedHours;


  MainScreenModel(this._appState) {
    _loadProcedureRecords();
  }


  void _loadProcedureRecords() async{
    var records = await SQLiteDbProvider.db.findAllProcedureRecords(_date.year, _date.month, _date.day);
    _procedureRecords = records;
    _workedHours = _calculateWorkedHours();
    notifyListeners();
  }


  ProcedureRecord getProcedureRecordAt(int index) {
    return _procedureRecords[index];
  }


  void addProcedureRecord(ProcedureRecord record) {
    _procedureRecords.insert(0, record);
    _workedHours = _calculateWorkedHours();
    notifyListeners();
  }


  void refreshWorkedHours() {
    _workedHours = _calculateWorkedHours();
    notifyListeners();
  }


  void deleteLastRecord() async{
    await SQLiteDbProvider.db.deleteProcedureRecord(_procedureRecords[0]);
    _procedureRecords.removeAt(0);
    _workedHours = _calculateWorkedHours();
    notifyListeners();
  }


  double _calculateWorkedHours() {
    double workedHours = 0;
    _procedureRecords.forEach((f) {
      if (f.timeSpent == null || f.procedure.id == 1) return;
      workedHours += f.timeSpent;
    });
    return workedHours;
  }
}