import 'package:app/domain/procedure.dart';


class ProcedureImmutable {
  int _id;
  int get id => _id;

  String _name;
  String get name => _name;

  ProcedureType _type;
  ProcedureType get type => _type;

  ProcedureImmutable(this._id, this._name, this._type);
}