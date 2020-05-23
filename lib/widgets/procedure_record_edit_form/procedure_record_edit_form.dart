import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_model.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ProcedureRecordEditForm extends StatelessWidget {


  ProcedureRecordEditForm();


  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey();
    var model = Provider.of<ProcedureRecordEditFormModel>(context);

    return Form(
      key: _formKey,
      autovalidate: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            initialValue: model.recordQuantity.toString(),
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
              model.quantity = int.parse(val);
            },
          ),

          SizedBox(height: 15),

          Consumer<ProcedureRecordEditFormModel>(
              builder: (context, model, _) => DropdownButtonFormField(
                isExpanded: true,
                hint: Text('Zvolte akci'),
                value: model.selectedProcedure,
                items: model.procedures.map((k, v) {
                  return MapEntry(k, DropdownMenuItem(value: k, child: Text(v.name, style: TextStyle(fontSize: 15))));
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
                  model.selectedProcedure = value;
                },
              )
          ),

          SizedBox(height: 15),

          RaisedButton(
            child: Text('Uložit'),
            onPressed: () async{
              if (!_formKey.currentState.validate()) {
                return;
              }
              _formKey.currentState.save();
              ResultObject<void> result = await model.save();

              Navigator.pop(context, result);
            },
          )
        ],
      ),
    );
  }
}
