import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/foundation.dart';


class ProcedureItemWidgetModel with ChangeNotifier {
  Procedure _procedure;

  int get id => _procedure.id;
  String get name => _procedure.name;

  ProcedureType get type => _procedure.type;


  // form
  String newName;


  ProcedureItemWidgetModel(this._procedure) {
    newName = _procedure.name;
  }


  void save(String newName) async{
    if (newName.isEmpty) throw ArgumentError();
    _procedure.name = newName;
    await SQLiteDbProvider.db.updateProcedure(_procedure);
    notifyListeners();
  }
}