import 'package:app/domain/procedure.dart';
import 'package:app/screens/summary/summary_screen_states.dart';
import 'package:flutter/material.dart';


class Summary extends StatelessWidget {

  final SummaryScreenState _state;


  Summary(this._state, {key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    if (_state is SummaryScreenLoadInProgress) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_state is SummaryScreenLoadFailure) {
      return Center(
        child: Text(
          (_state as SummaryScreenLoadFailure).errorMessage,
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    var state = (_state as SummaryScreenLoadSuccess);
    if (state.records.isEmpty) {
      return Center(child: Text('Nebyly nalezeny žádné záznamy.'));
    }

    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: state.records.length,
      itemBuilder: (BuildContext context, int index) {
        var summary = state.records.elementAt(index);
        return Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text(
                  summary.name,
                  style: TextStyle(
                    fontSize: 15,
                    color: summary.type == ProcedureType.BREAK ?
                      Colors.black45 :
                      Colors.black,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  summary.isBreak ? '-' : '${summary.quantity} ks',
                  style: TextStyle(
                    color: summary.type == ProcedureType.BREAK ?
                      Colors.black45 :
                      Colors.black,
                  ),
                  textAlign: TextAlign.center
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  '${summary.timeSpent} h',
                  style: TextStyle(
                    color: summary.type == ProcedureType.BREAK ?
                      Colors.black45 :
                      Colors.black,
                  ),
                  textAlign: TextAlign.right
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
