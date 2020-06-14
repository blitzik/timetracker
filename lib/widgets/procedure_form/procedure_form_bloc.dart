import 'package:app/widgets/procedure_form/procedure_form_events.dart';
import 'package:app/widgets/procedure_form/procedure_form_states.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ProcedureFormBloc extends Bloc<ProcedureFormEvent, ProcedureFormState> {
  final ProcedureImmutable _procedure;


  @override
  ProcedureFormState get initialState => ProcedureFormDefault(_procedure);


  ProcedureFormBloc(this._procedure);


  @override
  Stream<ProcedureFormState> mapEventToState(ProcedureFormEvent event) async*{
    if (event is ProcedureFormSent) {
      yield* _procedureFormSentToState(event);
    }
  }


  Stream<ProcedureFormState> _procedureFormSentToState(ProcedureFormSent event) async*{
    yield ProcedureFormProcessingSuccess(state.procedure, event.newProcedureName);
  }


  void dispose() {
    this.close();
  }
}