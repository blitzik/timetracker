import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_events.dart';
import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_states.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_states.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_bloc.dart';
import 'package:app/screens/editable_overview/editable_overview_events.dart' as eoEvents;
import 'package:app/screens/editable_overview/editable_overview_bloc.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/app_bloc.dart';
import 'dart:async';


class ProcedureRecordItemWidgetBloc extends Bloc<ProcedureRecordItemEvent, ProcedureRecordItemState> {
  final EditableOverviewBloc _editableOverviewBloc;
  final ProcedureRecordImmutable _procedureRecord;
  final AppBloc _appBloc;


  StreamSubscription<ProcedureRecordEditFormState> _editFormSubscription;
  ProcedureRecordEditFormBloc _editFormBloc;
  ProcedureRecordEditFormBloc get editFormBloc {
    if (_editFormBloc != null) {
      _editFormBloc.close();
      _editFormSubscription.cancel();
    }
    _editFormBloc = ProcedureRecordEditFormBloc(state.record, (_appBloc.state as AppLoadSuccess).procedures);
    _editFormSubscription = _editFormBloc.listen((onDataState) {
      if (onDataState is EditFormProcessingSuccess) {
        this.add(ProcedureRecordUpdated(onDataState.quantity, onDataState.selectedProcedure));
      }
    });
    return _editFormBloc;
  }


  @override
  ProcedureRecordItemState get initialState => ProcedureRecordItemDefaultState(_procedureRecord);


  ProcedureRecordItemWidgetBloc(
    this._editableOverviewBloc,
    this._procedureRecord,
    this._appBloc
  ) : assert(_editableOverviewBloc != null),
      assert(_procedureRecord != null),
      assert(_appBloc != null);


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


  Stream<ProcedureRecordItemState> _procedureRecordOpenedToState(ProcedureRecordOpened event) async*{
    var update = await SQLiteDbProvider.db.openProcedureRecord(state.record);
    if (update.isSuccess) {
      yield ProcedureRecordItemDefaultState(update.value);
      _editableOverviewBloc.add(eoEvents.ProcedureRecordUpdated(update.value));
    }
  }


  Stream<ProcedureRecordItemState> _procedureRecordClosedToState(ProcedureRecordClosed event) async*{
    yield ProcedureRecordItemDefaultState(event.record);
    _editableOverviewBloc.add(eoEvents.ProcedureRecordUpdated(event.record));
  }


  Stream<ProcedureRecordItemState> _procedureRecordUpdatedToState(ProcedureRecordUpdated event) async*{
    if (state.record.quantity == event.quantity && state.record.procedureName == event.procedure.name) {
      return;
    }

    var update = await SQLiteDbProvider.db.updateProcedureRecord(state.record, event.procedure, event.quantity);
    if (update.isSuccess) {
      yield ProcedureRecordItemDefaultState(update.value);
      _editableOverviewBloc.add(eoEvents.ProcedureRecordUpdated(update.value));
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