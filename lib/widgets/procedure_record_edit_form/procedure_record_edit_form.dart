import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_events.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_states.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_bloc.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ProcedureRecordEditForm extends StatefulWidget {

  ProcedureRecordEditForm();

  @override
  _ProcedureRecordEditFormState createState() => _ProcedureRecordEditFormState();
}



class _ProcedureRecordEditFormState extends State<ProcedureRecordEditForm> {
  GlobalKey<FormState> _formKey;
  ProcedureRecordEditFormBloc _bloc;

  int _quantity;
  String _selectedProcedure;

  bool _isQuantityFieldVisible;


  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<ProcedureRecordEditFormBloc>(context);
    _quantity = _bloc.state.record.quantity;
    _selectedProcedure = _bloc.state.record.procedureName;
    _formKey = GlobalKey();

    _isQuantityFieldVisible = _bloc.state.record.isClosed && !_bloc.state.record.isBreak;

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
        var st = (state as EditFormState);
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildForm(st)
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


  List<Widget> _buildForm(EditFormState state) {
    List<Widget> content = List();

    if (_isQuantityFieldVisible) {
      content.add(TextFormField(
        initialValue: _quantity == null ? null : _quantity.toString(),
        style: TextStyle(fontSize: 18),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(
          labelText: 'Počet',
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
      ));

      content.add(SizedBox(height: 15));
    }

    content.add(
      DropdownSearch<String>(
        mode: Mode.BOTTOM_SHEET,
        hint: 'Zvolte akci',
        label: 'Akce',
        showSelectedItem: true,
        showSearchBox: true,
        items: state.procedures.map((key, value) => MapEntry(key, value.name)).values.toList(),
        selectedItem: _selectedProcedure,
        onChanged: (v) {
          setState(() {
            _selectedProcedure = v;
            _isQuantityFieldVisible = state.procedures[_selectedProcedure].type != ProcedureType.BREAK && state.record.isClosed;
            _quantity = null;
          });
        }
      )
    );

    content.add(SizedBox(height: 15));

    content.add(RaisedButton(
      child: Text('Uložit'),
      onPressed: () {
        if (!_formKey.currentState.validate()) {
          return;
        }
        _formKey.currentState.save();
        _bloc.add(EditFormSent(_quantity, state.procedures[_selectedProcedure]));
      },
    ));


    return content;
  }
}