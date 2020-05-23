import 'package:app/widgets/procedure_item_widget/procedure_item_widget_model.dart';
import 'package:app/widgets/procedure_form/procedure_form_model.dart';
import 'package:app/widgets/procedure_form/procedure_form.dart';
import 'package:app/utils/result_object/result_object.dart';
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
        var result = await _openEditDialog(context, procedure);
        if (result == null) return;

        ScaffoldState ss = Scaffold.of(context);
        Text text = Text('Akce byla úspěšně uložena');
        Icon icon = Icon(Icons.done, color: Colors.lightGreen);

        if (!result.isSuccess) {
          text = Text(result.lastMessage);
          icon = Icon(Icons.error, color: Colors.red);
        }

        ss.showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          content: ListTile(
            title: text,
            trailing: icon,
          ),
        ));
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


  Future<ResultObject<Procedure>> _openEditDialog(BuildContext _context, ProcedureItemWidgetModel procedureModel) async{

    return showDialog(
      context: _context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Úprava záznamu'),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(25),
              child: ChangeNotifierProvider(
                create: (context) => ProcedureFormModel(procedureModel.name),
                child: ProcedureForm(
                  (context, formModel) async{
                    var parentModel = Provider.of<ProcedureItemWidgetModel>(_context, listen: false);

                    ResultObject<Procedure> result = await parentModel.save(formModel.procedureName);
                    if (!result.isSuccess) {
                      formModel.procedureNameErrorText = result.lastMessage;
                      return;
                    }
                    Navigator.pop(context, result);
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