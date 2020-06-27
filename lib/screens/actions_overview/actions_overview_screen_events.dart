abstract class ActionsOverviewScreenEvent {}


class ActionsOverviewLoaded extends ActionsOverviewScreenEvent {}


class ActionsOverviewProcedureAdded extends ActionsOverviewScreenEvent {
  final String newProcedureName;

  ActionsOverviewProcedureAdded(this.newProcedureName);
}