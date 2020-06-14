abstract class ProcedureFormEvent {}


class ProcedureFormSent extends ProcedureFormEvent {
  final String newProcedureName;

  ProcedureFormSent(this.newProcedureName);
}