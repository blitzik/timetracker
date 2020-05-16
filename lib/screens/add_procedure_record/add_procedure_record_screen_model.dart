import 'package:app/extensions/datetime_extension.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/foundation.dart';
import 'package:app/app_state.dart';
import 'dart:collection';


class AddProcedureRecordScreenModel with ChangeNotifier {

  final AppState _appState;

  final ProcedureRecord _lastRecord;
  bool get isLastProcedureSet => _lastRecord != null;
  String get procedureName => _lastRecord?.procedure?.name;
  DateTime get start => _lastRecord?.start;

  bool get isLunchBreak => _lastRecord?.procedure?.id == 1;


  Map<String, Procedure> _procedures = Map();
  UnmodifiableMapView<String, Procedure> get procedures => UnmodifiableMapView(_procedures);

  // form
  String selectedProcedure;
  int lastProcedureQuantity;
  DateTime newActionStart;


  AddProcedureRecordScreenModel(this._lastRecord, this._appState) {
    _procedures = _loadProcedures();
  }


  Map<String, Procedure> _loadProcedures() {
    Map<String, Procedure> procedures = Map();
    Procedure p1 = Procedure.withId(2, 'AAAAA');
    Procedure p2 = Procedure.withId(3, 'BBBBB');
    Procedure p3 = Procedure.withId(4, 'CCCCC');
    Procedure p4 = Procedure.withId(5, 'DDDDD');
    Procedure p5 = Procedure.withId(6, 'EEEEE');

    procedures[p1.name] = p1;
    procedures[p2.name] = p2;
    procedures[p3.name] = p3;
    procedures[p4.name] = p4;
    procedures[p5.name] = p5;

    return procedures;
  }


  ProcedureRecord startNewAction() {
    _lastRecord?.closeRecord(newActionStart, lastProcedureQuantity);

    Map<String, dynamic> map = Map();
    map['id'] = _lastRecord == null ? 1 : _lastRecord.id + 1;
    map['procedure_id'] = _procedures[selectedProcedure].id;
    map['procedure_name'] = _procedures[selectedProcedure].name;
    map['year'] = _lastRecord != null ? _lastRecord.year : _appState.date.year;
    map['month'] = _lastRecord != null ? _lastRecord.month : _appState.date.month;
    map['day'] = _lastRecord != null ? _lastRecord.day : _appState.date.day;
    map['week'] = _lastRecord != null ? _lastRecord.week : _appState.date.getWeek();
    map['quantity'] = null;
    map['start'] = _getCleanDateTime(newActionStart).millisecondsSinceEpoch;
    map['finish'] = null;
    map['time_spent'] = null;

    return ProcedureRecord.fromMap(map);
  }


  DateTime _getCleanDateTime(DateTime d) {
    return DateTime(d.year, d.month, d.day, d.hour, d.minute, 0, 0, 0);
  }
}