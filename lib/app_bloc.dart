import 'package:flutter_bloc/flutter_bloc.dart';


class AppBloc extends Bloc<DateTime, AppState>{

  @override
  AppState get initialState => AppState(DateTime.now());

  @override
  Stream<AppState> mapEventToState(DateTime event) async*{
    yield AppState(event);
  }
}


class AppState {
  final DateTime date;

  const AppState(this.date);
}