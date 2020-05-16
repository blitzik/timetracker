import 'package:app/domain/procedure_record.dart';
import 'package:flutter/foundation.dart';

class ProcedureRecordItemWidgetModel with ChangeNotifier {

  final ProcedureRecord _procedureRecord;
  int get id => _procedureRecord.id;

  final bool _isLast;
  bool get isLast => _isLast;

  int get procedureId => _procedureRecord.procedure.id;
  String get procedureName => _procedureRecord.procedure.name;
  DateTime get start => _procedureRecord.start;
  DateTime get finish => _procedureRecord.finish;
  double get timeSpent => _procedureRecord.timeSpent;
  int get quantity => _procedureRecord.quantity;
  ProcedureRecordState get state => _procedureRecord.state;


  ProcedureRecordItemWidgetModel(this._procedureRecord, this._isLast);


  void closeRecord(DateTime finish, int quantity) {
    _procedureRecord.closeRecord(finish, quantity);
    notifyListeners();
  }


  void openRecord() {
    _procedureRecord.openRecord();
    notifyListeners();
  }
}