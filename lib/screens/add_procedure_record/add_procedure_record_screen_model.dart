import 'package:app/storage/sqlite_db_provider.dart';
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
  DateTime get finish => _lastRecord?.finish;
  int get quantity => _lastRecord?.quantity;

  ProcedureType get procedureType => _lastRecord?.procedure?.type;


  Map<String, Procedure> _procedures = Map();
  UnmodifiableMapView<String, Procedure> get procedures => UnmodifiableMapView(_procedures);

  // form
  String selectedProcedure;
  int lastProcedureQuantity;
  DateTime newActionStart;


  AddProcedureRecordScreenModel(this._lastRecord, this._appState) {
    _loadProcedures();
  }


  void _loadProcedures() async{
    var procedures = await SQLiteDbProvider.db.findAllProcedures();

    Map<String, Procedure> result = Map();
    procedures.forEach((procedure) {
      result[procedure.name] = procedure;
    });

    _procedures = result;
    notifyListeners();
  }


  Future<ProcedureRecord> startNewAction() async{
    return await SQLiteDbProvider.db.startProcedureRecord(_lastRecord, lastProcedureQuantity, _procedures[selectedProcedure], newActionStart);
  }
}