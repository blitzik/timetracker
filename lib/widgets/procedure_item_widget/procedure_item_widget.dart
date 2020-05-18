import 'package:app/utils/result_object/result_object.dart';
import 'package:app/widgets/procedure_item_widget/procedure_item_widget_model.dart';
import 'package:app/screens/actions_overview/action_form_model.dart';
import 'package:app/screens/actions_overview/action_form.dart';
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
              return Text(procedure.name, style: TextStyle(fontSize: 15));
            }
        )
    );
  }


  void _openEditDialog(BuildContext _context, ProcedureItemWidgetModel procedureModel) async{

    return await showDialog(
      context: _context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Úprava záznamu'),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(25),
              child: ChangeNotifierProvider(
                create: (context) => ActionFormModel(procedureModel.name),
                child: ActionForm(
                  _context,
                  (context, formModel) async{
                    if (formModel.procedureName == procedureModel.name) {
                      Navigator.pop(context);
                      return;
                    }

                    var parentModel = Provider.of<ProcedureItemWidgetModel>(_context, listen: false);

                    ResultObject<Procedure> result = await parentModel.save(formModel.procedureName);
                    if (!result.isSuccess) {
                      formModel.procedureNameErrorText = result.lastMessage;
                      return;
                    }
                    Navigator.pop(context);
                  }
                ),
              ),
            )
          ],
        );
      }
    );
  }
}