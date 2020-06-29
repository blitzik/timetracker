import 'package:app/domain/procedure.dart';
import 'package:quiver/core.dart';


class ProcedureImmutable {
  int _id;
  int get id => _id;

  String _name;
  String get name => _name;

  ProcedureType _type;
  ProcedureType get type => _type;

  ProcedureImmutable(this._id, this._name, this._type);


  int get hashCode => hashObjects([name]);


  bool operator ==(o) =>
      (o is ProcedureImmutable) && o.name == this.name;
}