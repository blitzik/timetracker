import 'package:app/storage/sqlite_db_provider.dart';
import 'dart:collection';
import 'dart:async';


class ArchiveScreenModel {

  UnmodifiableListView<DateTime> _data = UnmodifiableListView(List());

  StreamController<UnmodifiableListView<DateTime>> _daysController = StreamController.broadcast();
  Stream<UnmodifiableListView<DateTime>> get daysStream => _daysController.stream;


  bool _isInit = false;

  ArchiveScreenModel();


  void init() async{
    if (_isInit == true) return;

    _daysController.add(await _loadData());

    _isInit = true;
  }


  Future<UnmodifiableListView<DateTime>> _loadData() async{
    var data = await SQLiteDbProvider.db.loadHistoryData();
    _data = UnmodifiableListView(data);
    return _data;
  }



  void dispose() {
    _daysController.close();
  }
}