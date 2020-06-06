import 'package:app/screens/add_procedure_record/add_procedure_record_screen_events.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen_states.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AddProcedureRecordScreenBloc extends Bloc<AddProcedureRecordEvent, AddProcedureRecordState> {
  final ProcedureRecord _lastRecord;


  @override
  AddProcedureRecordState get initialState => AddProcedureRecordStateInitial();


  @override
  Stream<AddProcedureRecordState> mapEventToState(AddProcedureRecordEvent event) async*{
    if (event is AddProcedureRecordFormSent) {
      yield* _addProcedureRecordFormSentToState(event);
    }
  }


  AddProcedureRecordScreenBloc(this._lastRecord);


  Stream<AddProcedureRecordState> _addProcedureRecordFormSentToState(AddProcedureRecordFormSent event) async*{

  }


  void _loadProcedures() async{
    var procedures = await SQLiteDbProvider.db.findAllProcedures();
  }


  void dispose() {
    this.close();
  }
}