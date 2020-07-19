import 'package:app/screens/summary/summary_screen_events.dart';
import 'package:app/screens/summary/summary_screen_states.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_summary.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:collection';
import 'dart:async';


enum SummaryType {
  day, week
}


class SummaryScreenBloc extends Bloc<SummaryScreenEvent, SummaryScreenState> {
  final DateTime _date;
  Map<SummaryType, SummaryScreenLoadSuccess> _summaryStates = Map();


  SummaryScreenBloc(this._date) : super(SummaryScreenLoadInProgress());


  @override
  Stream<SummaryScreenState> mapEventToState(SummaryScreenEvent event) async*{
    if (event is SummaryScreenLoaded) {
      yield* _summaryScreenLoadedToState(event);
    }
  }


  Stream<SummaryScreenState> _summaryScreenLoadedToState(SummaryScreenLoaded event) async*{
    if (_summaryStates.containsKey(event.summaryPeriod)) {
      yield _summaryStates[event.summaryPeriod];
      return;
    }

    yield SummaryScreenLoadInProgress();
    var result = await _loadData(event.summaryPeriod, _date);
    if (result.isSuccess) {
      var summary =  SummaryScreenLoadSuccess(_date, event.summaryPeriod, UnmodifiableListView(result.value));
      yield summary;
      _summaryStates[event.summaryPeriod] = summary;

    } else {
      yield SummaryScreenLoadFailure(_date, event.summaryPeriod, result.lastMessage);
    }
  }


  Future<ResultObject<List<ProcedureSummary>>> _loadData(SummaryType type, DateTime date) async{
    Future<ResultObject<List<ProcedureSummary>>> summaryFuture;
    if (type == SummaryType.day) {
      summaryFuture = SQLiteDbProvider.db.getDaySummary(
        date.year,
        date.month,
        date.day
      );
    } else {
      summaryFuture = SQLiteDbProvider.db.getWeekSummary(
        date.year,
        date.getWeek()
      );
    }

    return summaryFuture;
  }


  void dispose() {
    this.close();
  }
}