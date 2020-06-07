import 'package:app/domain/procedure_record.dart';
import 'package:app/domain/procedure.dart';


class ProcedureRecordImmutable {
   String _procedureName;
   String get procedureName => _procedureName;

   ProcedureType _procedureType;
   ProcedureType get procedureType => _procedureType;

   DateTime _start;
   DateTime get start => _start;

   DateTime _finish;
   DateTime get finish => _finish;

   int _quantity;
   int get quantity => _quantity;

   double _timeSpent;
   double get timeSpent => _timeSpent;

   bool _isBreak;
   bool get isBreak =>_isBreak;

   bool _isOpened;
   bool get isOpened => _isOpened;

   bool _isClosed;
   bool get isClosed => _isClosed;


  ProcedureRecordImmutable(ProcedureRecord record) {
    _procedureName = record?.procedure?.name;
    _procedureType = record?.procedure?.type;
    _start = record?.start;
    _finish = record?.finish;
    _quantity = record?.quantity;
    _timeSpent = record?.timeSpent;
    _isBreak = record?.isBreak;
    _isOpened = record?.isOpened;
    _isClosed = record?.isClosed;
  }
}