import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:flutter/foundation.dart';
import 'package:app/app_state.dart';


class ActionsOverviewScreeModel with ChangeNotifier {
  AppState _appState;

  DateTime get _date => _appState.date;

  List<Procedure> _procedures = List();
  bool get isListEmpty => _procedures.isEmpty;
  int get proceduresCount => _procedures.length;


  ActionsOverviewScreeModel(this._appState) {
    loadProcedures();
  }


  void loadProcedures() async{
    var procedures = await SQLiteDbProvider.db.findAllProcedures();
    _procedures = procedures;
    notifyListeners();
  }


  Future<ResultObject<Procedure>> save(String name) async{
    if (name == null || name.isEmpty) throw ArgumentError();
    Procedure newProcedure = Procedure(name);
    ResultObject<Procedure> result = await SQLiteDbProvider.db.insertProcedure(newProcedure);
    if (result.isSuccess) {
      _procedures.insert(0, newProcedure);
      notifyListeners();
    }
    return result;
  }


  Procedure getProcedureAt(int index) {
    return _procedures[index];
  }

}