import 'package:app/widgets/procedure_record_closing_form/procedure_record_closing_form_events.dart';
import 'package:app/widgets/procedure_record_closing_form/procedure_record_closing_form_states.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ProcedureRecordClosingFormBloc extends Bloc<ProcedureRecordClosingEvent, ProcedureRecordClosingFormState> {

  final ProcedureRecordImmutable _record;
  final bool _isFirstRecordOfDay;


  @override
  ProcedureRecordClosingFormState get initialState => ProcedureRecordClosingFormDefault(_record, _isFirstRecordOfDay);


  ProcedureRecordClosingFormBloc(this._record, this._isFirstRecordOfDay);


  @override
  Stream<ProcedureRecordClosingFormState> mapEventToState(ProcedureRecordClosingEvent event) async*{
    if (event is ProcedureRecordClosed) {
      yield* _procedureRecordClosedToState(event);
    }
  }


  Stream<ProcedureRecordClosingFormState> _procedureRecordClosedToState(ProcedureRecordClosed event) async*{
    if (state is ProcedureRecordClosingFormDefault) {
      var st = (state as ProcedureRecordClosingFormDefault);
      yield ProcedureRecordClosingInProgress();

      var update = await SQLiteDbProvider.db.closeProcedureRecord(st.record, event.finish, event.quantity);
      if (update.isSuccess) {
        yield ProcedureRecordClosingSuccess(update.value, st.isFirstRecordOfDay);

      } else {
        yield ProcedureRecordClosingFailure(update.lastMessage);
      }
    }
  }


  void dispose() {
    this.close();
  }
}