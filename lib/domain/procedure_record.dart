import 'package:app/exceptions/entity_identity_exception.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/domain/procedure.dart';


enum ProcedureRecordState {
  opened, closed
}


class ProcedureRecord {
  int _id;
  int get id => _id;
  set id(int id) {
    if (_id != null)
      throw EntityIdentityException('You cannot set ID to existing Entity');
    _id = id;
  }

  Procedure procedure;

  bool get isBreak => procedure.type == ProcedureType.BREAK;

  int _year;
  int get year => _year;
  int _month;
  int get month => _month;
  int _day;
  int get day => _day;
  int _week;
  int get week => _week;

  int _quantity;
  int get quantity => _quantity;
  set quantity(int quantity) {
    if (quantity < 0) throw ArgumentError('Only numbers higher than 0 can be passed');
    _quantity = quantity;
  }

  int _start;
  DateTime get start => DateTime.fromMillisecondsSinceEpoch(_start).toUtc();
  set __start(DateTime start) {
    _start = _getCleanDateTimeUTC(start).millisecondsSinceEpoch;
    _year = start.year;
    _month = start.month;
    _day = start.day;
    _week = start.getWeek();
  }

  int _finish;
  DateTime get finish => _finish == null ? null : DateTime.fromMillisecondsSinceEpoch(_finish).toUtc();
  set __finish(DateTime finish) {
    if (finish == null) {
      return;
    }
    _finish = _getCleanDateTimeUTC(finish).millisecondsSinceEpoch;
    _timeSpent = (_finish - _start) ~/ 1000;
  }

  int _timeSpent;
  double get timeSpent => _timeSpent == null ? null : _timeSpent / 3600;


  ProcedureRecordState get state {
    if (finish != null && (isBreak || quantity != null)) {
      return ProcedureRecordState.closed;
    }

    return ProcedureRecordState.opened;
  }


  ProcedureRecord(this.procedure, DateTime start) {
    this.__start = start;
  }


  ProcedureRecord._(
      this._id,
      this.procedure,
      this._year,
      this._month,
      this._day,
      this._week,
      this._quantity,
      this._start,
      this._finish,
      this._timeSpent
  );


  void openRecord() {
    _finish = null;
    _quantity = null;
    _timeSpent = null;
  }


  void closeRecord(DateTime finish, int quantity) {
    __finish = finish;
    _quantity = quantity;
  }


  DateTime _getCleanDateTimeUTC(DateTime d) {
    return DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, 0, 0, 0);
  }


  factory ProcedureRecord.fromMap(Map<String, dynamic> map) {
     return ProcedureRecord._(
        map['id'],
        Procedure.fromMap(map),
        map['year'],
        map['month'],
        map['day'],
        map['week'],
        map['quantity'],
        map['start'],
        map['finish'],
        map['time_spent']
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'procedure': procedure.id,
      'year': _year,
      'month': _month,
      'day': _day,
      'week': _week,
      'quantity': quantity,
      'start': _start,
      'finish': _finish == null ? null : _finish,
      'time_spent': _timeSpent,
    };
  }
}