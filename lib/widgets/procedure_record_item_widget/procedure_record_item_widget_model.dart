import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_record.dart';
import 'dart:async';


class ProcedureRecordItemWidgetModel  {

  StreamController<ProcedureRecordItemWidgetModel> _ownStreamController = StreamController.broadcast();
  Stream<ProcedureRecordItemWidgetModel> get ownStream => _ownStreamController.stream;

  final ProcedureRecord _procedureRecord;
  ProcedureRecord get procedureRecord => _procedureRecord;


  final bool _isLast;
  bool get isLast => _isLast;
  bool get isBreak => _procedureRecord.isBreak;

  String get procedureName => _procedureRecord.procedure.name;
  DateTime get start => _procedureRecord.start;
  DateTime get finish => _procedureRecord.finish;
  int get quantity => _procedureRecord.quantity;

  double get timeSpent => _procedureRecord.timeSpent;
  ProcedureRecordState get state => _procedureRecord.state;


  ProcedureRecordItemWidgetModel(this._procedureRecord, this._isLast);


  void closeRecord(DateTime finish, int quantity) async{
    _procedureRecord.closeRecord(finish, quantity);
    SQLiteDbProvider.db.updateProcedureRecord(_procedureRecord);
    _ownStreamController.add(this);
  }


  void openRecord() async{
    _procedureRecord.openRecord();
    SQLiteDbProvider.db.updateProcedureRecord(_procedureRecord);
    _ownStreamController.add(this);
  }


  void refresh() {
    _ownStreamController.add(this);
  }


  void dispose() {
    _ownStreamController.close();
  }
}