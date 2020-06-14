import 'package:app/domain/procedure_immutable.dart';
import 'dart:collection';


abstract class ActionsOverviewScreenState {}


class ActionsOverviewLoadInProgress extends ActionsOverviewScreenState {}


class ActionsOverviewLoadSuccess extends ActionsOverviewScreenState {
  UnmodifiableListView<ProcedureImmutable> procedures;

  ActionsOverviewLoadSuccess(this.procedures);
}


class ActionsOverviewLoadFailure extends ActionsOverviewScreenState {
  final String errorMessage;

  ActionsOverviewLoadFailure(this.errorMessage);
}