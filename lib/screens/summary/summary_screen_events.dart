import 'package:app/screens/summary/summary_screen_bloc.dart';


abstract class SummaryScreenEvent {}


class SummaryScreenLoaded extends SummaryScreenEvent {
  final SummaryType summaryPeriod;

  SummaryScreenLoaded(this.summaryPeriod);
}