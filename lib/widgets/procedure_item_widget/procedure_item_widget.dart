import 'package:app/widgets/procedure_item_widget/procedure_item_widget_model.dart';
import 'package:app/domain/procedure.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';


class ProcedureItemWidget extends StatelessWidget{

  ProcedureItemWidget();

  @override
  Widget build(BuildContext context) {
    var procedure = Provider.of<ProcedureItemWidgetModel>(context, listen: false);

    if (procedure.type == ProcedureType.BREAK) {
      return getBody(procedure);
    }

    return InkWell(
      child: getBody(procedure),
      onTap: () async{
        await _openEditDialog(context, procedure);
      },
    );
  }


  Widget getBody(ProcedureItemWidgetModel procedure) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        child: Consumer<ProcedureItemWidgetModel>(
            builder: (context, model, _) {
              return Text(procedure.name);
            }
        )
    );
  }


  void _openEditDialog(BuildContext _context, ProcedureItemWidgetModel procedureModel) async{
    var nameController = TextEditingController();
    nameController.text = procedureModel.name;
    GlobalKey<FormState> _formKey = GlobalKey();

    return await showDialog(
      context: _context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Úprava záznamu'),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                autovalidate: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Název akce'
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'Zadejte název akce';
                        return null;
                      },
                      onSaved: (value) {
                        procedureModel.newName = value;
                      },
                    ),

                    Text('(${procedureModel.name})', textAlign: TextAlign.right,),

                    SizedBox(height: 15),

                    RaisedButton(
                      child: const Text('uložit'),
                      onPressed: () {
                        if (!_formKey.currentState.validate()) return;
                        _formKey.currentState.save();

                        procedureModel.save(nameController.text);
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        );
      }
    );
  }
}