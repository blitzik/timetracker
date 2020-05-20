import 'package:app/widgets/procedure_item_widget/procedure_item_widget_model.dart';
import 'package:app/screens/actions_overview/actions_overview_screen_model.dart';
import 'package:app/widgets/procedure_item_widget/procedure_item_widget.dart';
import 'package:app/widgets/procedure_form/procedure_form_model.dart';
import 'package:app/widgets/procedure_form/procedure_form.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';


class ActionsOverviewScreen extends StatelessWidget {
  static const routeName = '/actionsOverview';


  ActionsOverviewScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Přehled akcí'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Consumer<ActionsOverviewScreeModel>(
          builder: (context, model, _) {
            return ListView.separated(
              itemCount: model.proceduresCount,
              separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                Procedure procedure = model.getProcedureAt(index);
                return ChangeNotifierProvider(
                  key: ValueKey(procedure.id),
                  create: (context) => ProcedureItemWidgetModel(procedure),
                  child: ProcedureItemWidget(),
                );
              }
          );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xff34495e),
        onPressed: () async{
          await _openProcedureCreationDialog(context);
        },
      ),
    );
  }


  void _openProcedureCreationDialog(BuildContext _context) async{
    return await showDialog(
        context: _context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Nová akce'),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(25),
                child: ChangeNotifierProvider(
                  create: (context) => ProcedureFormModel(),
                  child: ProcedureForm(
                    (context, formModel) async{
                      var parentModel = Provider.of<ActionsOverviewScreeModel>(_context, listen: false);

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