import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_record.dart';
import 'dart:collection';
import 'dart:async';


class MainScreenModel {
  List<ProcedureRecord> _records = List();

  StreamController<MainScreenModel> _ownStreamController = StreamController.broadcast();
  Stream<MainScreenModel> get ownStream => _ownStreamController.stream;

  StreamController<UnmodifiableListView<ProcedureRecord>> _procedureRecordsController = StreamController.broadcast();
  Stream<UnmodifiableListView<ProcedureRecord>> get procedureRecordsStream => _procedureRecordsController.stream;

  StreamController<ProcedureRecord> _addProcedureRecordController = StreamController.broadcast();
  StreamSink<ProcedureRecord> get addProcedureRecord => _addProcedureRecordController.sink;
  StreamSubscription<ProcedureRecord> _addProcedureRecordSubscription;

  StreamController<DateTime> _loadProcedureRecordsController = StreamController.broadcast();
  StreamSink<DateTime> get loadProcedureRecords => _loadProcedureRecordsController.sink;
  StreamSubscription<DateTime> _loadProcedureRecordsSubscription;

  StreamController<double> _workedHoursController = StreamController.broadcast();
  Stream<double> get workedHoursStream => _workedHoursController.stream;

  ProcedureRecord get lastProcedureRecord => _records != null && _records.isNotEmpty ? _records[0] : null;


  MainScreenModel() {
    _loadProcedureRecordsSubscription = _loadProcedureRecordsController.stream.listen((date) async{
      _records = await _loadData(date);
      _procedureRecordsController.add(UnmodifiableListView(_records));
      _workedHoursController.add(_calculateWorkedHours(_records));
    });

    _addProcedureRecordSubscription = _addProcedureRecordController.stream.listen((procedureRecord) {
      _records.insert(0, procedureRecord);
      _workedHoursController.add(_calculateWorkedHours(_records));
      _procedureRecordsController.add(UnmodifiableListView(_records));
    });
  }


  Future<List<ProcedureRecord>> _loadData(DateTime date) {
    return SQLiteDbProvider.db.findAllProcedureRecords(date.year, date.month, date.day);
  }


  double _calculateWorkedHours(List<ProcedureRecord> records) {
    double workedHours = 0;
    records.forEach((f) {
      if (f.timeSpent == null || f.procedure.id == 1) return;
      workedHours += f.timeSpent;
    });
    return workedHours;
  }


  void deleteLastRecord() async{
    if (_records != null && _records.isNotEmpty) {
      SQLiteDbProvider.db.deleteProcedureRecord(_records[0]);
    }
    _records.removeAt(0);
    _workedHoursController.add(_calculateWorkedHours(_records));
    _procedureRecordsController.add(UnmodifiableListView(_records));
  }


  void refreshWorkedHours() {
    _workedHoursController.add(_calculateWorkedHours(_records));
  }


  void dispose() {
    _ownStreamController.close();
    _procedureRecordsController.close();
    _workedHoursController.close();
    _loadProcedureRecordsController.close();
    _addProcedureRecordController.close();

    _loadProcedureRecordsSubscription.cancel();
    _addProcedureRecordSubscription.cancel();
  }
}