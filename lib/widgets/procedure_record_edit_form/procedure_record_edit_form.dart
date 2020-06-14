import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_events.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_states.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ProcedureRecordEditForm extends StatefulWidget {

  ProcedureRecordEditForm();

  @override
  _ProcedureRecordEditFormState createState() => _ProcedureRecordEditFormState();
}



class _ProcedureRecordEditFormState extends State<ProcedureRecordEditForm> {

  GlobalKey<FormState> _formKey = GlobalKey();
  ProcedureRecordEditFormBloc _bloc;

  int _quantity;
  String _selectedProcedure;


  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<ProcedureRecordEditFormBloc>(context);
    _quantity = _bloc.state.record.quantity;
    _selectedProcedure = _bloc.state.record.procedureName;

    _bloc.add(EditFormInitialized());
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProcedureRecordEditFormBloc, ProcedureRecordEditFormState>(
      buildWhen: (oldState, newState) {
        if (newState is EditFormProcessingSuccess) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        if (state is EditFormProceduresLoadInProgress) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is EditFormProceduresLoadFailure) {
          return Center(
            child: ListTile(
              title: Text(state.errorMessage, style: TextStyle(color: Colors.red)),
            ),
          );
        }

        var st = (state as EditFormState);
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                initialValue: _quantity.toString(),
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

              SizedBox(height: 15),

              DropdownButtonFormField(
                isExpanded: true,
                hint: Text('Zvolte akci'),
                value: _selectedProcedure,
                items: st.procedures.map((k, v) {
                  return MapEntry(k, DropdownMenuItem(value: k, child: Text(v.name, style: TextStyle(fontSize: 15))));
                }).values.toList(),
                onChanged: (v) {
                  _selectedProcedure = v;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Zvolte prosím jakou akcí chcete pokračovat.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _selectedProcedure = value;
                },
              ),

              SizedBox(height: 15),

              RaisedButton(
                child: Text('Uložit'),
                onPressed: () {
                  if (!_formKey.currentState.validate()) {
                    return;
                  }
                  _formKey.currentState.save();
                  _bloc.add(EditFormSent(_quantity, st.procedures[_selectedProcedure]));
                },
              )
            ],
          ),
        );
      },
      listener: (_context, newSTate) {
        if (newSTate is EditFormProcessingSuccess) {
          Navigator.pop(context);
        }
      },
    );
  }
}
