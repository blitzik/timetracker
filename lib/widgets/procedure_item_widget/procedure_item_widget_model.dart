import 'package:app/utils/result_object/result_object.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/foundation.dart';


class ProcedureItemWidgetModel with ChangeNotifier {
  Procedure _procedure;

  int get id => _procedure.id;
  String get name => _procedure.name;

  ProcedureType get type => _procedure.type;

  ProcedureItemWidgetModel(this._procedure);


  Future<ResultObject<Procedure>> save(String newName) async{
    if (newName == null || newName.isEmpty) throw ArgumentError();

    if (_procedure.name == newName) return Future.value(ResultObject(_procedure));

    String oldName = _procedure.name;
    _procedure.name = newName;

    ResultObject<Procedure> result = await SQLiteDbProvider.db.updateProcedure(_procedure);
    if (!result.isSuccess) {
      _procedure.name = oldName;
    }

    notifyListeners();
    return result;
  }
}