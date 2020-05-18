import 'package:app/screens/actions_overview/actions_overview_screen_model.dart';
import 'package:app/screens/actions_overview/action_form_model.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/domain/procedure.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ActionForm extends StatelessWidget {
  final BuildContext _context;
  final Function(BuildContext context, ActionFormModel formModel)
      _onSaveClicked;

  ActionForm(this._context, this._onSaveClicked);

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey();
    var model = Provider.of<ActionFormModel>(context, listen: false);

    return Form(
      key: _formKey,
      autovalidate: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _getWidgets(context, model, _formKey)
      ),
    );
  }

  List<Widget> _getWidgets(BuildContext context, ActionFormModel model, GlobalKey<FormState> _formKey) {
    List<Widget> body = List();
    body.add(Consumer<ActionFormModel>(
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
      onPressed: () async {
        if (!_formKey.currentState.validate()) return;

        _onSaveClicked(context, model);
      },
    ));

    return body;
  }
}
