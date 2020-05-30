import 'package:app/extensions/datetime_extension.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_summary.dart';
import 'dart:collection';
import 'dart:async';


enum SummaryType {
  day, week
}


class SummaryScreenModel {
  DateTime _date;
  DateTime get date => _date;

  List<ProcedureSummary> _summary = List();

  StreamController<SummaryScreenModel> _modelStream = StreamController.broadcast();
  Stream<SummaryScreenModel> get modelStream => _modelStream.stream;

  StreamController<UnmodifiableListView<ProcedureSummary>> _procedureSummaryController = StreamController.broadcast();
  Stream<UnmodifiableListView<ProcedureSummary>> get procedureSummariesStream => _procedureSummaryController.stream;

  StreamController<SummaryType> _summaryTypeController = StreamController.broadcast();
  StreamSink<SummaryType> get loadSummary => _summaryTypeController.sink;
  StreamSubscription<SummaryType> _summarySubscription;

  StreamController<double> _workedHoursController = StreamController.broadcast();
  Stream<double> get workedHoursStream => _workedHoursController.stream;

  SummaryType _currentType;
  SummaryType get currentType =>_currentType;


  SummaryScreenModel(this._date) {
    _currentType = SummaryType.day;
    _modelStream.add(this);

    _summarySubscription = _summaryTypeController.stream.listen((summaryType) async{
      _currentType = summaryType;
      _procedureSummaryController.add(await _loadData(currentType));
      _modelStream.add(this);
    });
  }


  Future<UnmodifiableListView<ProcedureSummary>> _loadData(SummaryType type) async{
    List<ProcedureSummary> summary;
    if (type == SummaryType.day) {
      summary = await SQLiteDbProvider.db.getDaySummary(
        date.year,
        date.month,
        date.day
      );
    } else {
      summary = await SQLiteDbProvider.db.getWeekSummary(
        date.year,
        date.getWeek()
      );
    }
    double workedHours = 0;
    _summary = summary.toList(growable: false);
    _summary.forEach((f) {
      workedHours += f.timeSpent;
    });
    _workedHoursController.add(workedHours);

    return Future.value(UnmodifiableListView(_summary));
  }


  void dispose() {
    _modelStream.close();
    _procedureSummaryController.close();
    _workedHoursController.close();
    _summaryTypeController.close();

    _summarySubscription.cancel();
  }
}