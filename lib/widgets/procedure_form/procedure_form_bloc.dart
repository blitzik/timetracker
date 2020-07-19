import 'package:app/widgets/procedure_form/procedure_form_events.dart';
import 'package:app/widgets/procedure_form/procedure_form_states.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ProcedureFormBloc extends Bloc<ProcedureFormEvent, ProcedureFormState> {


  ProcedureFormBloc(ProcedureImmutable procedure) : super(ProcedureFormDefault(procedure));


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