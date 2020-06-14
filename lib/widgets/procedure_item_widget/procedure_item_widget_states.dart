import 'package:app/domain/procedure_immutable.dart';

abstract class ProcedureItemState {
  final ProcedureImmutable procedure;

  ProcedureItemState(this.procedure);
}


class ProcedureItemDefaultState extends ProcedureItemState {
  ProcedureItemDefaultState(ProcedureImmutable procedure) : super(procedure);
}


class ProcedureItemUpdateSuccess extends ProcedureItemDefaultState {
  ProcedureItemUpdateSuccess(ProcedureImmutable procedure) : super(procedure);
}


class ProcedureItemUpdateFailure extends ProcedureItemDefaultState {
  final String errorMessage;

  ProcedureItemUpdateFailure(ProcedureImmutable procedure, this.errorMessage) : super(procedure);
}