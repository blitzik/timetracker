import 'package:app/domain/procedure.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter/foundation.dart';


class ProcedureRecordItemWidgetModel with ChangeNotifier {

  final ProcedureRecord _procedureRecord;
  int get id => _procedureRecord.id;

  final bool _isLast;
  bool get isLast => _isLast;

  ProcedureType get procedureType => _procedureRecord.procedure.type;
  String get procedureName => _procedureRecord.procedure.name;
  DateTime get start => _procedureRecord.start;
  DateTime get finish => _procedureRecord.finish;
  double get timeSpent => _procedureRecord.timeSpent;
  int get quantity => _procedureRecord.quantity;
  ProcedureRecordState get state => _procedureRecord.state;


  ProcedureRecordItemWidgetModel(this._procedureRecord, this._isLast);


  void closeRecord(DateTime finish, int quantity) async{
    _procedureRecord.closeRecord(finish, quantity);
    SQLiteDbProvider.db.updateProcedureRecord(_procedureRecord);
    notifyListeners();
  }


  void openRecord() async{
    _procedureRecord.openRecord();
    SQLiteDbProvider.db.updateProcedureRecord(_procedureRecord);
    notifyListeners();
  }
}