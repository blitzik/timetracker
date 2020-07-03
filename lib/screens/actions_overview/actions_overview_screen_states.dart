import 'package:app/domain/procedure_immutable.dart';
import 'dart:collection';


abstract class ActionsOverviewScreenState {}


class ActionsOverviewLoadSuccess extends ActionsOverviewScreenState {
  UnmodifiableListView<ProcedureImmutable> procedures;

  ActionsOverviewLoadSuccess(this.procedures) : assert (procedures != null);
}


class ActionsOverviewLoadFailure extends ActionsOverviewScreenState {
  final String errorMessage;

  ActionsOverviewLoadFailure(this.errorMessage);
}


class ActionsOverviewProcedureSaveSuccess extends ActionsOverviewLoadSuccess {
  ActionsOverviewProcedureSaveSuccess(UnmodifiableListView<ProcedureImmutable> procedures) : super(procedures);
}


class ActionsOverviewProcedureSaveFailure extends ActionsOverviewScreenState {
  final String errorMessage;

  ActionsOverviewProcedureSaveFailure(this.errorMessage);
}