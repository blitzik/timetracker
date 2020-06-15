import 'package:app/screens/archive/archive_screen_events.dart';
import 'package:app/screens/archive/archive_screen_states.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:collection';
import 'dart:async';


class ArchiveScreenBloc extends Bloc<ArchiveScreenEvent, ArchiveScreenState>{

  @override
  ArchiveScreenState get initialState => ArchiveScreenLoadInProgress();


  ArchiveScreenBloc();


  @override
  Stream<ArchiveScreenState> mapEventToState(ArchiveScreenEvent event) async*{
    if (event is ArchiveScreenDaysLoaded) {
      yield* _archiveScreenDaysLoadedToState(event);
    }
  }


  Stream<ArchiveScreenState> _archiveScreenDaysLoadedToState(ArchiveScreenDaysLoaded event) async*{
    yield ArchiveScreenLoadInProgress();
    var search = await SQLiteDbProvider.db.findHistoryData();
    if (search.isSuccess) {
      yield ArchiveScreenLoadSuccessful(search.result);

    } else {
      yield ArchiveScreenLoadFailure(search.lastMessage);
    }
  }


  void dispose() {
    this.close();
  }

}