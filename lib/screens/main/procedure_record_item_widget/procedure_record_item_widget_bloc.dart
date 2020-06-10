import 'package:app/screens/main/procedure_record_item_widget/procedure_record_item_events.dart';
import 'package:app/screens/main/procedure_record_item_widget/procedure_record_item_states.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_states.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_bloc.dart';
import 'package:app/screens/main/main_screen_events.dart' as mainScreenEvents;
import 'package:app/screens/main/main_screen_bloc.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/domain/procedure.dart';
import 'dart:async';


class ProcedureRecordItemWidgetBloc extends Bloc<ProcedureRecordItemEvent, ProcedureRecordItemState> {
  final MainScreenBloc _mainScreenBloc;
  final ProcedureRecord _procedureRecord;
  final bool _isLast;


  StreamSubscription<ProcedureRecordEditFormState> _editFormSubscription;
  ProcedureRecordEditFormBloc _editFormBloc;
  ProcedureRecordEditFormBloc get editFormBloc {
    if (_editFormBloc != null) {
      _editFormBloc.close();
      _editFormSubscription.cancel();
    }
    _editFormBloc = ProcedureRecordEditFormBloc(_procedureRecord);
    _editFormSubscription = _editFormBloc.listen((onDataState) {
      if (onDataState is EditFormProcessingSuccess) {
        this.add(ProcedureRecordUpdated(onDataState.quantity, onDataState.selectedProcedure));
      }
    });
    return _editFormBloc;
  }


  @override
  ProcedureRecordItemState get initialState => ProcedureRecordItemLoaded(_procedureRecord.toImmutable(), _isLast);


  @override
  Stream<ProcedureRecordItemState> mapEventToState(ProcedureRecordItemEvent event) async*{
    if (event is ProcedureRecordOpened) {
      yield* _procedureRecordOpenedToState(event);

    } else if (event is ProcedureRecordClosed) {
      yield* _procedureRecordClosedToState(event);

    } else if (event is ProcedureRecordUpdated) {
      yield* _procedureRecordUpdatedToState(event);
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
      _mainScreenBloc.add(mainScreenEvents.ProcedureRecordUpdated(_procedureRecord));
    } else {
      _procedureRecord.closeRecord(oldFinish, oldQuantity);
    }
  }


  Stream<ProcedureRecordItemState> _procedureRecordClosedToState(ProcedureRecordClosed event) async*{
    _procedureRecord.closeRecord(event.finish, event.quantity);
    var result = await SQLiteDbProvider.db.updateProcedureRecord(_procedureRecord);
    if (result.isSuccess) {
      yield ProcedureRecordItemLoaded(_procedureRecord.toImmutable(), _isLast);
      _mainScreenBloc.add(mainScreenEvents.ProcedureRecordUpdated(_procedureRecord));
    } else {
      _procedureRecord.openRecord();
    }
  }


  Stream<ProcedureRecordItemState> _procedureRecordUpdatedToState(ProcedureRecordUpdated event) async*{
    if (event.procedure.id == _procedureRecord.procedure.id && event.quantity == _procedureRecord.quantity) {
      return;
    }

    Procedure oldProcedure = _procedureRecord.procedure;
    int oldQuantity = _procedureRecord.quantity;

    _procedureRecord.procedure = event.procedure;
    _procedureRecord.quantity = event.quantity;

    var result = await SQLiteDbProvider.db.updateProcedureRecord(_procedureRecord);
    if (result.isSuccess) {
      yield ProcedureRecordItemLoaded(_procedureRecord.toImmutable(), _isLast);

    } else {
      _procedureRecord.procedure = oldProcedure;
      _procedureRecord.quantity = oldQuantity;
    }
  }


  void dispose() {
    if (_editFormBloc != null) {
      _editFormBloc.dispose();
      _editFormSubscription.cancel();
    }
    this.close();
  }

  /*

  if (quantity == _record.quantity && selectedProcedure == _record.procedure.name) {
      return Future.value(ResultObject<void>());
    }

    var oldProcedure = _record.procedure;
    var oldQuantity = _record.quantity;

    _record.procedure = _procedures[selectedProcedure];
    _record.quantity = quantity;

    var result = await SQLiteDbProvider.db.updateProcedureRecord(_record);
    if (result.isSuccess) {
      _onSavedRecord?.call();
    } else {
      _record.procedure = oldProcedure;
      _record.quantity = oldQuantity;
    }
    return Future.value(result);

  */
}