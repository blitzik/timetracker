import 'package:app/screens/main/main_screen_events.dart';
import 'package:app/screens/main/procedure_record_item_widget/procedure_record_item_events.dart';
import 'package:app/screens/main/procedure_record_item_widget/procedure_record_item_states.dart';
import 'package:app/screens/main/main_screen_bloc.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';


class ProcedureRecordItemWidgetBloc extends Bloc<ProcedureRecordItemEvent, ProcedureRecordItemState> {
  final MainScreenBloc _mainScreenBloc;
  final ProcedureRecord _procedureRecord;
  final bool _isLast;


  @override
  ProcedureRecordItemState get initialState => ProcedureRecordItemLoaded(_procedureRecord.toImmutable(), _isLast);


  @override
  Stream<ProcedureRecordItemState> mapEventToState(ProcedureRecordItemEvent event) async*{
    if (event is ProcedureRecordOpened) {
      yield* _procedureRecordOpenedToState(event);

    } else if (event is ProcedureRecordClosed) {
      yield* _procedureRecordClosedToState(event);
    }
  }


  ProcedureRecordItemWidgetBloc(this._mainScreenBloc, this._procedureRecord, this._isLast) :
        assert(_mainScreenBloc != null),
        assert(_procedureRecord != null),
        assert(_isLast != null);


  Stream<ProcedureRecordItemState> _procedureRecordOpenedToState(ProcedureRecordOpened event) async*{
    DateTime oldFinish = _procedureRecord.finish;
    int oldQuantity = _procedureRecord.quantity;
    _procedureRecord.openRecord();
    var result = await SQLiteDbProvider.db.updateProcedureRecord(_procedureRecord);
    if (result.isSuccess) {
      yield ProcedureRecordItemLoaded(_procedureRecord.toImmutable(), _isLast);
      _mainScreenBloc.add(ProcedureRecordUpdated(_procedureRecord));

    } else {
      _procedureRecord.closeRecord(oldFinish, oldQuantity);
    }
  }


  Stream<ProcedureRecordItemState> _procedureRecordClosedToState(ProcedureRecordClosed event) async*{
    _procedureRecord.closeRecord(event.finish, event.quantity);
    var result = await SQLiteDbProvider.db.updateProcedureRecord(_procedureRecord);
    if (result.isSuccess) {
      yield ProcedureRecordItemLoaded(_procedureRecord.toImmutable(), _isLast);
      _mainScreenBloc.add(ProcedureRecordUpdated(_procedureRecord));

    } else {
      _procedureRecord.openRecord();
    }
  }


  /*void closeRecord(DateTime finish, int quantity) async{
    _procedureRecord.closeRecord(finish, quantity);
    await SQLiteDbProvider.db.updateProcedureRecord(_procedureRecord);
    _ownStreamController.add(this);
  }


  void openRecord() async{
    _procedureRecord.openRecord();
    SQLiteDbProvider.db.updateProcedureRecord(_procedureRecord);
    _ownStreamController.add(this);
  }*/


  void dispose() {
    this.close();
  }
}