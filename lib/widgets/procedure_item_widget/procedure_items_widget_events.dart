abstract class ProcedureItemWidgetEvent {}


class ProcedureUpdated extends ProcedureItemWidgetEvent {
  final String newName;

  ProcedureUpdated(this.newName);
}