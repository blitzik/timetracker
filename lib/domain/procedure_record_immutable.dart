import 'package:app/domain/procedure_record.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/material.dart';
import 'package:quiver/core.dart';


class ProcedureRecordImmutable {
  int _id;
  int get id => _id;

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
    _id = record.id;
    _procedureName = record.procedure.name;
    _procedureType = record.procedure.type;
    _start = record.start;
    _finish = record?.finish;
    _quantity = record?.quantity;
    _timeSpent = record?.timeSpent;
    _isBreak = record.isBreak;
    _isOpened = record.isOpened;
    _isClosed = record.isClosed;
  }


  int get hashCode => hashObjects([
    procedureName,
    start,
    finish,
    quantity,
    isBreak,
    isOpened,
  ]);


  bool operator ==(o) =>
    (o is ProcedureRecordImmutable) &&
    o.procedureName == this.procedureName &&
    o.start  == this.start &&
    o.finish == this.finish &&
    o.quantity == this.quantity &&
    o.isBreak  == this.isBreak &&
    o.isOpened == this.isOpened;
}