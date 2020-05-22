import 'package:app/screens/add_procedure_record/add_procedure_record_screen_model.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:app/domain/procedure.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class AddProcedureRecordScreen extends StatelessWidget {
  static const routeName = '/addProcedureRecord';

  final titleTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  AddProcedureRecordScreen();


  @override
  Widget build(BuildContext context) {
    var model = Provider.of<AddProcedureRecordScreenModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Nová akce'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1, color: Color(0xffcccccc))),

                ),
                child: Column(
                  crossAxisAlignment:  CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      child: Text('Poslední záznam', style: titleTextStyle),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Color(0xffcccccc)))),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: !model.isLastProcedureSet ?
                              Text('Nebyl nalezen žádný předchozí záznam.') :
                              LastRecordWidget(model.procedureName, model.start, model.finish)
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: _getQuantityTextField(model)
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Color(0xffcccccc)))),
                      child: Text(
                        'Nový záznam',
                        style: titleTextStyle,
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: Consumer<AddProcedureRecordScreenModel>(
                          builder: (context, model, _) => DropdownButtonFormField(
                            hint: Text('Zvolte akci'),
                            value: model.selectedProcedure,
                            items: model.procedures.map((k, v) {
                              return MapEntry(k, DropdownMenuItem(value: k, child: Text(v.name)));
                            }).values.toList(),
                            onChanged: (v) {
                              model.selectedProcedure = v;
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Zvolte prosím jakou akcí chcete pokračovat.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              //_formDTO.newProcedure = model.getProcedure(value);
                            },
                          )
                      ),
                    ),
                    Container(
                        height: 150,
                        decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
                        child: TimePickerSpinner(
                          time: _setDefaultTime(model),
                          isShowSeconds: false,
                          is24HourMode: true,
                          isForce2Digits: true,
                          minutesInterval: 15,
                          spacing: 75,
                          itemHeight: 50,
                          onTimeChange: (time) {
                            model.newActionStart = time;
                          },
                        )
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 60,
                      child: Consumer<AddProcedureRecordScreenModel>(
                        builder: (_, model, __) => RaisedButton(

                          child: Text('START'),
                          onPressed: () async{
                            if (!_formKey.currentState.validate()) {
                              return;
                            }
                            _formKey.currentState.save();
                            var newRecord = await model.startNewAction();
                            Navigator.pop(context, newRecord);
                          },
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }


  DateTime _setDefaultTime(AddProcedureRecordScreenModel model) {
    if (model.isLastProcedureSet) {
      if (model.finish != null) {
        return model.finish;
      }
    }
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minutes;
    if (now.minute >= 45) {
      hour++;
      minutes = 0;

    } else {
      minutes = (now.minute / 15).round() * 15;
    }

    return DateTime(now.year, now.month, now.day, hour, minutes, 0, 0, 0);
  }


  Widget _getQuantityTextField(AddProcedureRecordScreenModel model) {
    if (model.procedureType == ProcedureType.BREAK) {
      return null;
    }

    return TextFormField(
      style: TextStyle(fontSize: 18),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
        labelText: 'počet',
      ),
      initialValue: model?.quantity?.toString(),
      validator: (s) {
        if (s.isEmpty) {
          return 'Zadejte počet';
        }
        return null;
      },
      onSaved: (s) {
        model.lastProcedureQuantity = int.parse(s);
      },
    );
  }
}


class LastRecordWidget extends StatelessWidget {

  final String _procedureName;
  final DateTime _start;
  final DateTime _finish;


  LastRecordWidget(
      this._procedureName,
      this._start,
      this._finish
  );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(5),
      title: Text(_procedureName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      subtitle: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black54),
          children: <TextSpan>[
            TextSpan(text: '${DateFormat('Hm').format(_start)} - '),
            _finish != null ? TextSpan(text: '${DateFormat('Hm').format(_finish)}') : TextSpan(text: '')
          ]
        ),
      )
    );
  }
}