
import 'package:app/domain/procedure.dart';

class ProcedureSummary {
  final String _name;
  String get name => _name;

  final int _quantity;
  int get quantity => _quantity;

  final int _type;
  ProcedureType get type => ProcedureType.values[_type];

  bool get isBreak => type == ProcedureType.BREAK;

  final int _timeSpent;
  double get timeSpent => _timeSpent == null ? null : _timeSpent / 3600;



  ProcedureSummary._(this._name, this._type, this._quantity, this._timeSpent);


  factory ProcedureSummary.fromMap(Map<String, dynamic> map) {
    return ProcedureSummary._(
        map['name'],
        map['type'],
        map['quantity'],
        map['time_spent']
    );
  }
}