import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/foundation.dart';
import 'package:app/app_state.dart';
import 'package:provider/provider.dart';


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


  Future<Procedure> save(String name) async{
    if (name.isEmpty) throw ArgumentError();
    Procedure newProcedure = Procedure(name);
    await SQLiteDbProvider.db.insertProcedure(newProcedure);
    _procedures.insert(0, newProcedure);
    notifyListeners();
    return newProcedure;
  }


  Procedure getProcedureAt(int index) {
    return _procedures[index];
  }

}