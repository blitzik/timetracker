import 'package:app/screens/archive/archive_screen_events.dart';
import 'package:app/screens/archive/archive_screen_states.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:collection';
import 'dart:async';


class ArchiveScreenBloc extends Bloc<ArchiveScreenEvent, ArchiveScreenState>{

  @override
  ArchiveScreenState get initialState => ArchiveUninitialized();


  ArchiveScreenBloc();


  Stream<Transition<ArchiveScreenEvent, ArchiveScreenState>> transformEvents(
    Stream<ArchiveScreenEvent> events,
    TransitionFunction<ArchiveScreenEvent, ArchiveScreenState> transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }


  @override
  Stream<ArchiveScreenState> mapEventToState(ArchiveScreenEvent event) async*{
    if (event is FetchSummary) {
      yield* _fetchSummaryToState(event);
    }
  }


  Stream<ArchiveScreenState> _fetchSummaryToState(FetchSummary event) async*{
    if (state is ArchiveScreenLoadSuccessful) {
      if ((state as ArchiveScreenLoadSuccessful).hasReachedMax) {
        print('no data loaded');
        return;
      }
    }

    if (state is ArchiveUninitialized) {
      final historySearch = await SQLiteDbProvider.db.findHistoryData(0);
      if (historySearch.isSuccess) {
        yield ArchiveScreenLoadSuccessful(historySearch.result, false);
      } else {

        yield ArchiveScreenLoadFailure(historySearch.lastMessage);
      }
    }

    if (state is ArchiveScreenLoadSuccessful) {
      var st = state as ArchiveScreenLoadSuccessful;
      final historySearch = await SQLiteDbProvider.db.findHistoryData(st.days.length);
      if (historySearch.isSuccess) {
        if (historySearch.result.isEmpty) {
          yield st.copyWith(hasReachedMax: true);

        } else {
          List<DateTime> updatedItems = List.from(st.days)..addAll(historySearch.result);
          yield ArchiveScreenLoadSuccessful(UnmodifiableListView(updatedItems), false);
        }

      } else {
        yield ArchiveScreenLoadFailure(historySearch.lastMessage);
      }
    }
  }


  void dispose() {
    this.close();
  }

}