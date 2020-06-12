import 'package:app/screens/summary/summary_screen_bloc.dart';
import 'package:app/domain/procedure_summary.dart';
import 'dart:collection';


abstract class SummaryScreenState {}


abstract class SummaryScreenPeriodState extends SummaryScreenState {
  final DateTime date;
  final SummaryType summaryPeriod;

  SummaryScreenPeriodState(this.date, this.summaryPeriod);
}


class SummaryScreenLoadInProgress extends SummaryScreenState {}


class SummaryScreenLoadSuccess extends SummaryScreenPeriodState {
  final UnmodifiableListView<ProcedureSummary> records;

  double _workedHours;
  double get workedHours => _workedHours;

  final SummaryType summaryPeriod;


  SummaryScreenLoadSuccess(DateTime date, this.summaryPeriod, this.records) : super(date, summaryPeriod) {
    double workedHours = 0;
    records.forEach((f) {
      workedHours += f.timeSpent;
    });
    _workedHours = workedHours;
  }
}


class SummaryScreenLoadFailure extends SummaryScreenPeriodState {
  final String errorMessage;

  SummaryScreenLoadFailure(DateTime date, SummaryType summaryPeriod, this.errorMessage) : super(date, summaryPeriod);
}