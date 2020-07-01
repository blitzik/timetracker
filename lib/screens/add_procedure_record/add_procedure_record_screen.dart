import 'package:app/screens/add_procedure_record/add_procedure_record_screen_events.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen_states.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen_bloc.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/utils/result_object/time_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class AddProcedureRecordScreen extends StatefulWidget {
  static const String routeName = '/addProcedureRecord';


  AddProcedureRecordScreen();

  @override
  _AddProcedureRecordScreenState createState() => _AddProcedureRecordScreenState();
}


class _AddProcedureRecordScreenState extends State<AddProcedureRecordScreen> {
  TextStyle _titleTextStyle;
  GlobalKey<FormState> _formKey;


  String _selectedProcedure;
  int _lastProcedureQuantity;
  DateTime _newActionStart;


  AddProcedureRecordScreenBloc _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<AddProcedureRecordScreenBloc>(context);

    _titleTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    _formKey = GlobalKey<FormState>();
  }


  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Container(
                          child: Text('Poslední záznam', style: _titleTextStyle),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Color(0xffcccccc)))),
                        ),
                      ),
                      BlocBuilder<AddProcedureRecordScreenBloc, AddProcedureRecordState>(
                        builder: (context, state) {
                          return Row(
                          children: <Widget>[
                            Expanded(
                              child: LastRecordWidget(state.lastRecord),
                            ),
                            SizedBox(
                              width: 100,
                              child: _getQuantityTextField(state)
                            )
                          ],
                        );}
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
                          style: _titleTextStyle,
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        child: BlocBuilder<AddProcedureRecordScreenBloc, AddProcedureRecordState>(
                          condition: (oldState, newState) {
                            if (newState is AddProcedureRecordFormProcessingSucceeded ||
                                newState is AddProcedureRecordFormProcessingFailed) {
                              return false;
                            }
                            return true;
                          },
                          builder: (context, state) {
                            var st = (state as AddProcedureRecordFormState);
                            return DropdownSearch<String>(
                              mode: Mode.BOTTOM_SHEET,
                              hint: 'Zvolte akci',
                              showSelectedItem: true,
                              showSearchBox: true,
                              items: st.procedures.map((key, value) => MapEntry(key, value.name)).values.toList(),
                              selectedItem: _selectedProcedure,
                              onChanged: (v) {
                                _selectedProcedure = v;
                              }
                            );
                          }
                        )
                      ),
                      BlocBuilder<AddProcedureRecordScreenBloc, AddProcedureRecordState>(
                        condition: (oldState, newState) {
                          if (newState is AddProcedureRecordFormProcessingSucceeded ||
                              newState is AddProcedureRecordFormProcessingFailed) {
                            return false;
                          }
                          return true;
                        },
                        builder: (context, state) {
                          return Container(
                            height: 150,
                            decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
                            child: TimePickerSpinner(
                              time: _setDefaultTime((state as AddProcedureRecordFormState).lastRecord),
                              isShowSeconds: false,
                              is24HourMode: true,
                              isForce2Digits: true,
                              minutesInterval: 15,
                              spacing: 40,
                              itemHeight: 50,
                              itemWidth: 50,
                              onTimeChange: (time) {
                                _newActionStart = time;
                              },
                            )
                          );
                        }
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 60,
                        child: Builder(
                          builder: (context) => BlocConsumer<AddProcedureRecordScreenBloc, AddProcedureRecordState>(
                            listener: (_context, currentState) {
                              if (currentState is AddProcedureRecordFormProcessingSucceeded) {
                                Navigator.pop(context, currentState);
                              }

                              if (currentState is AddProcedureRecordFormProcessingFailed) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: ListTile(
                                    title: Text(currentState.message),
                                    trailing: Icon(Icons.error, color: Colors.red),
                                  ),
                                ));
                              }
                            },
                            buildWhen: (oldState, newState) {
                              if (newState is AddProcedureRecordFormProcessingSucceeded ||
                                  newState is AddProcedureRecordFormProcessingFailed) {
                                return false;
                              }
                              return true;
                            },
                            builder: (context, state) {
                              var st = (state as AddProcedureRecordFormState);
                              return RaisedButton(
                                child: Text('START'),
                                onPressed: () async{
                                  if (!_formKey.currentState.validate()) {
                                    return;
                                  }
                                  _formKey.currentState.save();

                                  _bloc.add(AddProcedureRecordFormSent(
                                    _lastProcedureQuantity,
                                    _newActionStart,
                                    st.procedures[_selectedProcedure]
                                  ));
                                },
                              );
                            }
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }

  DateTime _setDefaultTime(ProcedureRecordImmutable lastRecord) {
    if (lastRecord != null) {
      if (lastRecord.finish != null) {
        return lastRecord.finish;
      }
    }

    return TimeUtils.findClosestTime(DateTime.now(), 15);
  }


  Widget _getQuantityTextField(AddProcedureRecordState state) {
    var lastRecord = state.lastRecord;
    if (lastRecord == null || lastRecord.procedureType == ProcedureType.BREAK) {
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
      initialValue: lastRecord?.quantity?.toString(),
      validator: (s) {
        if (s.isEmpty) {
          return 'Zadejte počet';
        }
        return null;
      },
      onSaved: (s) {
        _lastProcedureQuantity = int.parse(s);
      },
    );
  }
}


class LastRecordWidget extends StatelessWidget {

  final ProcedureRecordImmutable _lastRecord;


  LastRecordWidget(
    this._lastRecord
  );

  @override
  Widget build(BuildContext context) {
    if (_lastRecord == null) {
      return Text('Nebyl nalezen žádný předchozí záznam.');
    }

    return ListTile(
      contentPadding: const EdgeInsets.all(5),
      title: Text(_lastRecord.procedureName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      subtitle: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black54),
          children: <TextSpan>[
            TextSpan(text: '${DateFormat('Hm').format(_lastRecord.start)} - '),
            _lastRecord.finish != null ? TextSpan(text: '${DateFormat('Hm').format(_lastRecord.finish)}') : TextSpan(text: '')
          ]
        ),
      )
    );
  }
}