import 'package:app/exceptions/entity_identity_exception.dart';

enum ProcedureType {
  BREAK, WORK
}


class Procedure {
  int _id;
  int get id => _id;
  set id(int id) {
    if (_id != null)
      throw EntityIdentityException('You cannot set ID to existing Entity');
    _id = id;
  }

  String name;

  int _type;
  ProcedureType get type => ProcedureType.values[_type];


  Procedure(this.name) {
    _type = ProcedureType.WORK.index;
  }
  Procedure._(this._id, this.name, this._type);


  factory Procedure.fromMap(Map<String, dynamic> map) {
    return Procedure._(map['procedure_id'], map['procedure_name'], map['procedure_type']);
  }


  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'type': this._type,
    };
  }
}