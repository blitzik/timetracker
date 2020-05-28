import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:app/app_state.dart';
import 'dart:async';


class MainScreenModel {
  AppState _appState;

  StreamController<MainScreenModel> _ownStreamController = StreamController.broadcast();
  Stream<MainScreenModel> get ownStream => _ownStreamController.stream;

  DateTime get _date => _appState.date;

  List<ProcedureRecord> _procedureRecords = List();
  int get procedureRecordsCount => _procedureRecords.length;
  bool get isProcedureRecordsEmpty => _procedureRecords.isEmpty;

  ProcedureRecord get lastProcedureRecord => _procedureRecords.isEmpty ? null : _procedureRecords.first;
  int get lastProcedureRecordIndex => _procedureRecords.length - 1;

  double _workedHours = 0;
  double get workedHours => _workedHours;

  Duration _duration;
  Timer _timer;

  MainScreenModel(this._appState) {
    /*_duration = Duration(seconds: 5);
    Timer.periodic(Duration(seconds: 5), (timer) {
      print('5 seconds duration DONE!');
      timer.cancel();
      _timer = Timer.periodic(Duration(seconds: 10), (timer) {
        print('10 seconds duration DONE!');
      });
    });*/
    _loadProcedureRecords();
  }


  void _loadProcedureRecords() async{
    var records = await SQLiteDbProvider.db.findAllProcedureRecords(_date.year, _date.month, _date.day);
    _procedureRecords = records;
    _workedHours = _calculateWorkedHours();
    _ownStreamController.add(this);
  }


  ProcedureRecord getProcedureRecordAt(int index) {
    return _procedureRecords[index];
  }


  void addProcedureRecord(ProcedureRecord record) {
    _procedureRecords.insert(0, record);
    _workedHours = _calculateWorkedHours();
    _ownStreamController.add(this);
  }


  void refreshWorkedHours() {
    _workedHours = _calculateWorkedHours();
    _ownStreamController.add(this);
  }


  void deleteLastRecord() async{
    await SQLiteDbProvider.db.deleteProcedureRecord(_procedureRecords[0]);
    _procedureRecords.removeAt(0);
    _workedHours = _calculateWorkedHours();
    _ownStreamController.add(this);
  }


  double _calculateWorkedHours() {
    double workedHours = 0;
    _procedureRecords.forEach((f) {
      if (f.timeSpent == null || f.procedure.id == 1) return;
      workedHours += f.timeSpent;
    });
    return workedHours;
  }


  void dispose() {
    _ownStreamController.close();
  }
}