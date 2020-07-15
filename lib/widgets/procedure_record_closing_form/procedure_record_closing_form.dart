import 'package:app/widgets/procedure_record_closing_form/procedure_record_closing_form_events.dart';
import 'package:app/widgets/procedure_record_closing_form/procedure_record_closing_form_states.dart';
import 'package:app/widgets/procedure_record_closing_form/procedure_record_closing_form_bloc.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/widgets/time_picker/time_picker.dart';
import 'package:app/utils/result_object/time_utils.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/utils/result_object/style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';


class ProcedureRecordClosingForm extends StatefulWidget {

  ProcedureRecordClosingForm();


  @override
  _ProcedureRecordClosingFormState createState() => _ProcedureRecordClosingFormState();
}


class _ProcedureRecordClosingFormState extends State<ProcedureRecordClosingForm> {
  ProcedureRecordClosingFormBloc _bloc;
  GlobalKey<FormState> _formKey;
  int _quantity;
  DateTime _finish;
  double _timeSpent = 0.0;

  Color _buttonColor;

  ProcedureRecordImmutable _record;


  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<ProcedureRecordClosingFormBloc>(context);
    _record = (_bloc.state as ProcedureRecordClosingFormDefault).record;

    _finish = _getDefaultTime(_record);
    _buttonColor = Style.COLOR_GREEN_SEA;

    _timeSpent = _calcTime(_record.start, _finish);

    _formKey = GlobalKey();
  }


  double _calcTime(DateTime start, DateTime finish) {
    finish = finish.copyWithAsUTC(year: start.year, month: start.month, day: start.day, second: 0, millisecond: 0, microsecond: 0);
    if (finish.hour == 0) {
      final tempTime = finish.add(const Duration(days: 1));
      final updatedTime  = DateTime.utc(tempTime.year, tempTime.month, tempTime.day, 0, finish.minute, 0, 0, 0);
      finish = updatedTime;
    }
    int t = (finish.millisecondsSinceEpoch - start.millisecondsSinceEpoch) ~/ 1000;
    return t / 3600;
  }


  DateTime _getDefaultTime(ProcedureRecordImmutable record) {
    var startTime = record.start;
    var dn = DateTime.now();
    var now = DateTime.utc(startTime.year, startTime.month, startTime.day, dn.hour, dn.minute, 0, 0, 0);
    if (now.isBefore(startTime)) {
      return startTime;
    }

    return TimeUtils.findClosestTime(now, 15);
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProcedureRecordClosingFormBloc, ProcedureRecordClosingFormState>(
      listener: (context, state) {
        if (state is ProcedureRecordClosingSuccess) {
          Navigator.pop(context, state.record);
        }
      },

      buildWhen: (oldState, newState) {
        if (newState is ProcedureRecordClosingSuccess) {
          return false;
        }
        return true;
      },

      builder: (context, state) {
        if (state is ProcedureRecordClosingInProgress) {
          return Center(
            child: Column(
              children: <Widget>[
                Text('Probíhá uzavírání záznamu...'),
                CircularProgressIndicator()
              ],
            ),
          );
        }

        if (state is ProcedureRecordClosingFailure) {
          return Center(
            child: Text(
              state.errorMessage,
              style: TextStyle(color: Style.COLOR_POMEGRANATE),
            ),
          );
        }

        var st = (state as ProcedureRecordClosingFormDefault);
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: _getFormTopRowContent(_record)
              ),

              SizedBox(height: 15),

              Container(
                height: 150,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black)
                ),
                child: SizedBox(
                  width: 250,
                  child: TimePicker(
                    hours: List.generate(24, (index) => index),
                    minutes: [0, 15, 30, 45],
                    time: _finish,
                    onTimeChanged: (time) {
                      setState(() {
                        if (time.hour == 0) {
                          time = time.copyWith(second: 0, millisecond: 0, microsecond: 0);
                        }
                        _finish = time;
                        _timeSpent = _calcTime(st.record.start, _finish);

                        if (_timeSpent <= 0) {
                          _buttonColor = Style.COLOR_POMEGRANATE;
                        } else {
                          _buttonColor = Style.COLOR_GREEN_SEA;
                        }
                      });
                    },
                  ),
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

                  DateTime finish = _finish;
                  if (st.isFirstRecordOfDay == false) {
                    finish = _finish.add(const Duration(days: 1))..copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
                  }
                  _bloc.add(ProcedureRecordClosed(finish, _quantity));
                },
              )
            ],
          ),
        );
      }
    );
  }


  List<Widget> _getFormTopRowContent(ProcedureRecordImmutable record) {
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
}