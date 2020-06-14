import 'package:app/screens/main/procedure_record_item_widget/procedure_record_item_events.dart';
import 'package:app/screens/main/procedure_record_item_widget/procedure_record_item_states.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_states.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_bloc.dart';
import 'package:app/screens/main/main_screen_events.dart' as mainScreenEvents;
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/screens/main/main_screen_bloc.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';


class ProcedureRecordItemWidgetBloc extends Bloc<ProcedureRecordItemEvent, ProcedureRecordItemState> {
  final MainScreenBloc _mainScreenBloc;
  final ProcedureRecordImmutable _procedureRecord;
  final bool _isLast;


  StreamSubscription<ProcedureRecordEditFormState> _editFormSubscription;
  ProcedureRecordEditFormBloc _editFormBloc;
  ProcedureRecordEditFormBloc get editFormBloc {
    if (_editFormBloc != null) {
      _editFormBloc.close();
      _editFormSubscription.cancel();
    }
    _editFormBloc = ProcedureRecordEditFormBloc(state.record);
    _editFormSubscription = _editFormBloc.listen((onDataState) {
      if (onDataState is EditFormProcessingSuccess) {
        this.add(ProcedureRecordUpdated(onDataState.quantity, onDataState.selectedProcedure));
      }
    });
    return _editFormBloc;
  }


  @override
  ProcedureRecordItemState get initialState => ProcedureRecordItemDefaultState(_procedureRecord, _isLast);


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


  ProcedureRecordItemWidgetBloc(
    this._mainScreenBloc,
    this._procedureRecord,
    this._isLast
  ) : assert(_mainScreenBloc != null),
      assert(_procedureRecord != null),
      assert(_isLast != null);


  Stream<ProcedureRecordItemState> _procedureRecordOpenedToState(ProcedureRecordOpened event) async*{
    var update = await SQLiteDbProvider.db.openProcedureRecord(state.record);
    if (update.isSuccess) {
      yield ProcedureRecordItemDefaultState(update.result, _isLast);
      _mainScreenBloc.add(mainScreenEvents.ProcedureRecordUpdated(update.result));
    }
  }


  Stream<ProcedureRecordItemState> _procedureRecordClosedToState(ProcedureRecordClosed event) async*{
    var update = await SQLiteDbProvider.db.closeProcedureRecord(state.record, event.finish, event.quantity);
    if (update.isSuccess) {
      yield ProcedureRecordItemDefaultState(update.result, _isLast);
      _mainScreenBloc.add(mainScreenEvents.ProcedureRecordUpdated(update.result));
    }
  }


  Stream<ProcedureRecordItemState> _procedureRecordUpdatedToState(ProcedureRecordUpdated event) async*{
    var update = await SQLiteDbProvider.db.updateProcedureRecord(state.record, event.procedure, event.quantity);
    if (update.isSuccess) {
      yield ProcedureRecordItemDefaultState(update.result, _isLast);
    }
  }


  void dispose() {
    if (_editFormBloc != null) {
      _editFormBloc.dispose();
      _editFormSubscription.cancel();
    }
    this.close();
  }
}