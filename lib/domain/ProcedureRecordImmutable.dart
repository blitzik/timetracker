import 'package:app/domain/procedure.dart';
import 'package:flutter/foundation.dart';

@immutable
class ProcedureRecordImmutable {

  final String procedureName;
  final ProcedureType procedureType;
  final DateTime start;
  final DateTime finish;
  final int quantity;


  ProcedureRecordImmutable(
    this.procedureName,
    this.procedureType,
    this.start,
    this.finish,
    this.quantity
  );
}