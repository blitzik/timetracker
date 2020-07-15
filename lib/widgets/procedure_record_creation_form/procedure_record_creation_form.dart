import 'package:app/widgets/procedure_record_creation_form/procedure_record_creation_form_events.dart';
import 'package:app/widgets/procedure_record_creation_form/procedure_record_creation_form_states.dart';
import 'package:app/widgets/procedure_record_creation_form/procedure_record_creation_form_bloc.dart';
import 'package:app/widgets/time_picker/time_picker.dart';
import 'package:app/utils/result_object/time_utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:app/utils/result_object/style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:core';


class ProcedureRecordCreationForm extends StatefulWidget {



  @override
  _ProcedureRecordCreationFormState createState() => _ProcedureRecordCreationFormState();
}


class _ProcedureRecordCreationFormState extends State<ProcedureRecordCreationForm> {


  ProcedureRecordCreationFormBloc _bloc;
  String _selectedProcedure;
  DateTime _start;


  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<ProcedureRecordCreationFormBloc>(context);
    var lastRecord = (_bloc.state as ProcedureRecordCreationFormInitial).lastRecord;
    if (lastRecord != null) {
      _start = lastRecord.finish;

    } else {
      _start = TimeUtils.findClosestTime(DateTime.now(), 15);
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProcedureRecordCreationFormBloc, ProcedureRecordCreationFormState>(
      listener: (context, state) {
        if (state is ProcedureRecordCreationSuccess) {
          Navigator.pop(context, state.newRecord);
        }
      },
      buildWhen: (oldState, newState) {
        return !(newState is ProcedureRecordCreationSuccess);
      },
      builder: (context, state) {
        if (state is ProcedureRecordCreationInProgress) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Column(
                children: <Widget>[
                  Text('Ukládám záznam ...'),
                  SizedBox(height: 25),
                  CircularProgressIndicator()
                ],
              ),
            ),
          );
        }

        if (state is ProcedureRecordCreationFailure) {
          return Container(
            height: 300,
            child: Center(
              child: Text(state.errorMessage, style: TextStyle(color: Style.COLOR_POMEGRANATE)),
            ),
          );
        }

        var st = (state as ProcedureRecordCreationFormInitial);
        return Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Nový záznam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: _createProceduresDropdown(state),
              ),

              Expanded(
                child: st.lastRecord == null
                    ? _createTimePicker(st)
                    : Container()
              ),

              SizedBox(
                height: 50,
                child: RaisedButton(
                  color: Color(0xff2980b9),
                  textColor: Colors.white,
                  child: Text('Vytvořit záznam'),
                  onPressed: _selectedProcedure == null ? null : () {
                    _bloc.add(ProcedureRecordCreated(st.procedures[_selectedProcedure], _start));
                  },
                ),
              )
            ],
          ),
        );
      }
    );
  }


  Widget _createProceduresDropdown(ProcedureRecordCreationFormInitial st) {
    return DropdownSearch<String>(
      mode: Mode.BOTTOM_SHEET,
      hint: 'Zvolte akci',
      label: 'Akce',
      showSelectedItem: true,
      showSearchBox: true,
      items: st.procedures.map((key, value) => MapEntry(key, value.name)).values.toList(),
      selectedItem: _selectedProcedure,
      onChanged: (v) {
        setState(() {
          _selectedProcedure = v;
        });
      },
      validator: (s) {
        if (s == null) {
          return 'Zvolte prosím, jakou akcí chcete pokračovat.';
        }
        return null;
      },
    );
  }


  Widget _createTimePicker(ProcedureRecordCreationFormInitial st) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black12)),
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TimePicker(
        hours: List.generate(24, (index) => index),
        minutes: [0, 15, 30, 45],
        onTimeChanged: (time) {
          _start = time;
        },
      ),
    );
  }


  @override
  void dispose() {
    _bloc.dispose();

    super.dispose();
  }
}
