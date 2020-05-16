class Procedure {
  int _id;
  int get id => _id;

  String _name;
  String get name => _name;

  Procedure(this._name);
  Procedure.withId(this._id, this._name);


  factory Procedure.fromMap(Map<String, dynamic> map) {
    return Procedure.withId(map['id'], map['name']);
  }


  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this._name
    };
  }
}