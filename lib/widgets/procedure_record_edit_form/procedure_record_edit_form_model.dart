import 'package:app/utils/result_object/result_object.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/foundation.dart';
import 'dart:collection';


class ProcedureRecordEditFormModel with ChangeNotifier {

  ProcedureRecord _record;

  int get recordQuantity => _record.quantity;

  Function() _onSavedRecord;


  // form
  Map<String, Procedure> _procedures = Map();
  UnmodifiableMapView<String, Procedure> get procedures => UnmodifiableMapView(_procedures);

  int quantity;
  String selectedProcedure;


  ProcedureRecordEditFormModel(this._record, this._onSavedRecord) {
    _loadProcedures();
    selectedProcedure = _record.procedure.name;
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


  Future<ResultObject<void>> save() async{
    if (quantity == _record.quantity && selectedProcedure == _record.procedure.name) {
      return Future.value(ResultObject<void>());
    }

    _record.procedure = _procedures[selectedProcedure];
    _record.quantity = quantity;

    var result = await SQLiteDbProvider.db.updateProcedureRecord(_record);
    if (result.isSuccess) {
      _onSavedRecord?.call();
    }
    return Future.value(result);
  }

}