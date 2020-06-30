import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_widget_bloc.dart';
import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_events.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/utils/result_object/time_utils.dart';
import 'package:app/utils/result_object/style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';


class ProcedureRecordClosingForm extends StatefulWidget {

  final ProcedureRecordImmutable record;
  final BuildContext originContext;


  ProcedureRecordClosingForm(this.record, this.originContext);


  @override
  _ProcedureRecordClosingFormState createState() => _ProcedureRecordClosingFormState();
}


class _ProcedureRecordClosingFormState extends State<ProcedureRecordClosingForm> {
  ProcedureRecordItemWidgetBloc _bloc;
  GlobalKey<FormState> _formKey;
  int _quantity;
  DateTime _finish;
  double _timeSpent = 0.0;

  Color _buttonColor;


  @override
  void initState() {
    super.initState();

    _buttonColor = Style.COLOR_GREEN_SEA;

    _formKey = GlobalKey();
    _bloc = BlocProvider.of<ProcedureRecordItemWidgetBloc>(widget.originContext);
  }


  double _calcTime(DateTime start, DateTime finish) {
    int t = (_getCleanDateTime(start, finish).millisecondsSinceEpoch - start.millisecondsSinceEpoch) ~/ 1000;
    return t / 3600;
  }


  DateTime _getCleanDateTime(DateTime defaultTime, DateTime d) {
    return DateTime.utc(defaultTime.year, defaultTime.month, defaultTime.day, d.hour, d.minute, 0, 0, 0);
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
              children: _getFormTopRowContext(widget.record)
          ),

          SizedBox(height: 15),

          Container(
              height: 150,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black)
              ),
              child: TimePickerSpinner(
                isShowSeconds: false,
                is24HourMode: true,
                isForce2Digits: true,
                minutesInterval: 15,
                spacing: 40,
                itemHeight: 50,
                itemWidth: 50,
                time: _getDefaultTime(widget.record),
                onTimeChange: (time) {
                  setState(() {
                    _finish = time;
                    _timeSpent = _calcTime(widget.record.start, _finish);
                    if (_timeSpent <= 0) {
                      _buttonColor = Style.COLOR_POMEGRANATE;
                    } else {
                      _buttonColor = Style.COLOR_GREEN_SEA;
                    }
                  });
                },
              )
          ),

          RaisedButton(
            child: Text('Uzavřít záznam', style: TextStyle(color: Colors.white)),
            color: _buttonColor,
            onPressed: () {
              if (!_formKey.currentState.validate()) {
                return;
              }
              _formKey.currentState.save();

              _bloc.add(ProcedureRecordClosed(_finish, _quantity));

              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }


  List<Widget> _getFormTopRowContext(ProcedureRecordImmutable record) {
    List<Widget> content = List();

    content.add(
        Expanded(
          child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                '${_timeSpent.toString()} h',
                key: ValueKey(_timeSpent),
                style: TextStyle(fontSize: 18, color: _timeSpent > 0 ? Colors.black87 : Style.COLOR_POMEGRANATE),
              )
          ),
        )
    );

    if (!record.isBreak) {
      content.add(
          Expanded(
            child: TextFormField(
              style: TextStyle(fontSize: 18),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                labelText: 'počet',
              ),
              validator: (s) {
                if (s.isEmpty) {
                  return 'Zadejte počet';
                }
                return null;
              },
              onSaved: (val) {
                _quantity = int.parse(val);
              },
            ),
          )
      );
    }

    return content;
  }


  DateTime _getDefaultTime(ProcedureRecordImmutable record) {
    var startTime = record.start;
    var now = _getCleanDateTime(startTime, DateTime.now());
    if (now.isBefore(startTime)) {
      return startTime;
    }

    return TimeUtils.findClosestTime(now, 15);
  }
}