import 'package:app/widgets/procedure_form/procedure_form_events.dart';
import 'package:app/widgets/procedure_form/procedure_form_states.dart';
import 'package:app/widgets/procedure_form/procedure_form_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';


class ProcedureForm extends StatefulWidget {

  ProcedureForm();


  @override
  _ProcedureFormState createState() => _ProcedureFormState();
}


class _ProcedureFormState extends State<ProcedureForm> {
  GlobalKey<FormState> _formKey = GlobalKey();
  ProcedureFormBloc _bloc;

  String _procedureName;


  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<ProcedureFormBloc>(context);
    _procedureName = _bloc.state?.procedure?.name;
  }


  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProcedureFormBloc, ProcedureFormState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _getWidgets(context, state, _formKey)
          ),
        );
      }
    );
  }

  List<Widget> _getWidgets(BuildContext context, ProcedureFormState state, GlobalKey<FormState> _formKey) {
    List<Widget> body = List();
    body.add(TextFormField(
        initialValue: state?.procedure?.name,
        decoration: InputDecoration(
          labelText: 'Název akce'
        ),
        validator: (value) {
          if (value.trim().isEmpty) return 'Zadejte název akce';
          return null;
        },
        onChanged: (name) {
          _procedureName = name;
        },
      ),
    );

    if (state.procedure != null) {
      body.add(Text('(${state.procedure.name})', textAlign: TextAlign.right));
    }

    body.add(SizedBox(height: 15));
    body.add(BlocListener<ProcedureFormBloc, ProcedureFormState>(
      listener: (oldState, newState) {
        if (newState is ProcedureFormProcessingSuccess) {
          Navigator.pop(context);
        }
      },
      child: RaisedButton(
        child: const Text('uložit'),
        onPressed: () {
          if (!_formKey.currentState.validate()) return;
          _formKey.currentState.save();

          _bloc.add(ProcedureFormSent(_procedureName));
        },
      ),
    ));

    return body;
  }
}
