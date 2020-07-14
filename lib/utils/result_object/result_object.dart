class ResultObject<T> {
  T _result;
  T get value => _result;

  List<String> _errorMessages = List();
  String get lastMessage => _errorMessages.last;
  int get errorsCount => _errorMessages.length;
  bool get isSuccess => _errorMessages.isEmpty;
  bool get isFailure => _errorMessages.isNotEmpty;


  ResultObject([this._result]);

  void addErrorMessage(String message) {
    _errorMessages.add(message);
  }
}