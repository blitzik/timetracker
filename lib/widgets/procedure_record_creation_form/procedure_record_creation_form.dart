import 'package:app/lib/widgets/procedure_record_creation_form/procedure_record_creation_form_bloc.dart';
import 'package:app/widgets/procedure_record_creation_form/procedure_record_creation_form_states.dart';
import 'package:app/widgets/procedure_record_creation_form/procedure_record_creation_form_bloc.dart';
import 'package:dropdown_search/dropdown_search.dart';
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


  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<ProcedureRecordCreationFormBloc>(context);
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProcedureRecordCreationFormBloc, ProcedureRecordCreationFormState>(
      builder: (context, state) {
        var st = (state as ProcedureRecordCreationFormInitial);

        return Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Nový záznam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: _createProceduresDropdown(state),
              ),

              Expanded(child: Container()),
              SizedBox(
                height: 75,
                child: RaisedButton(

                  child: Text('Vytvořit záznam'),
                  onPressed: () {

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
        _selectedProcedure = v;
      },
      validator: (s) {
        if (s == null) {
          return 'Zvolte prosím, jakou akcí chcete pokračovat.';
        }
        return null;
      },
    );
  }


  @override
  void dispose() {


    super.dispose();
  }
}
