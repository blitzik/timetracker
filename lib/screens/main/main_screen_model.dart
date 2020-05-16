import 'package:app/domain/procedure_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MainScreenModel with ChangeNotifier {
  DateTime _date;

  List<ProcedureRecord> _procedureRecords = List();
  int get procedureRecordsCount => _procedureRecords.length;
  bool get isProcedureRecordsEmpty => _procedureRecords.isEmpty;

  ProcedureRecord get lastProcedureRecord => _procedureRecords.isEmpty ? null : _procedureRecords.first;
  int get lastProcedureRecordIndex => _procedureRecords.length - 1;

  double _workedHours = 0;
  double get workedHours => _workedHours;


  MainScreenModel(this._date);


  ProcedureRecord getProcedureRecordAt(int index) {
    return _procedureRecords[index];
  }


  void addProcedureRecord(ProcedureRecord record) {
    _procedureRecords.insert(0, record);
    _workedHours = _calculateWorkedHours();
    notifyListeners();
  }


  void refresh() {
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