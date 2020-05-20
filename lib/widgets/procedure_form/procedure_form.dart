import 'package:app/widgets/procedure_form/procedure_form_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';


class ProcedureForm extends StatelessWidget {
  final Function(BuildContext context, ProcedureFormModel formModel) _onSaveClicked;

  ProcedureForm(this._onSaveClicked);


  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey();
    var model = Provider.of<ProcedureFormModel>(context, listen: false);

    return Form(
      key: _formKey,
      autovalidate: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _getWidgets(context, model, _formKey)
      ),
    );
  }


  List<Widget> _getWidgets(BuildContext context, ProcedureFormModel model, GlobalKey<FormState> _formKey) {
    List<Widget> body = List();
    body.add(Consumer<ProcedureFormModel>(
      builder: (context, model, _) => TextFormField(
        initialValue: model.procedureName,
        decoration: InputDecoration(
            labelText: 'Název akce', errorText: model.procedureNameErrorText),
        validator: (value) {
          if (value.trim().isEmpty) return 'Zadejte název akce';
          return null;
        },
        onChanged: (s) {
          model.procedureName = s;
        },
      ),
    ));

    if (model.procedureName != null) {
      body.add(Text('(${model.procedureName})', textAlign: TextAlign.right));
    }

    body.add(SizedBox(height: 15));
    body.add(RaisedButton(
      child: const Text('uložit'),
      onPressed: () {
        if (!_formKey.currentState.validate()) return;

        _onSaveClicked(context, model);
      },
    ));

    return body;
  }
}
