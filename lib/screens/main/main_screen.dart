import 'package:app/widgets/procedure_record_item_widget/procedure_record_item_widget_model.dart';
import 'package:app/widgets/procedure_record_item_widget/procedure_record_item_widget.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen.dart';
import 'package:app/screens/actions_overview/actions_overview_screen.dart';
import 'package:app/screens/summary/summary_screen.dart';
import 'package:app/screens/main/main_screen_model.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/extensions/string_extension.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app/app_state.dart';
import 'package:intl/intl.dart';


class MainScreen extends StatelessWidget {
  static const routeName = '/';


  MainScreen();


  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context, listen: false);
    var screenModel = Provider.of<MainScreenModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('${appState.date.getWeek()}. týden'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 65,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Color(0xff34495e)),
                child: Text('Navigace', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),

            ListTile(
                title: Text('Přehled akcí'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, ActionsOverviewScreen.routeName);
                },
            ),

            ListTile(
              title: Text('Souhrn záznamů'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, SummaryScreen.routeName);
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              decoration: BoxDecoration(color: Color(0xfff0f0f0), border: Border(bottom: BorderSide(width: 1, color: Color(0xffcccccc)))),
              padding: EdgeInsets.symmetric(vertical: 15),
              child: ListTile(
                title: Text(
                  '${DateFormat('EEEE d. MMMM yyyy').format(appState.date).toString().capitalizeFirst()}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Selector<MainScreenModel, double>(
                  selector: (context, model) => model.workedHours,
                  builder: (context, workedHours, _) => Text('Celkem odpracováno: ${workedHours}h')
                ),
              )
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Selector<MainScreenModel, int>(
                  selector: (context, model) => model.procedureRecordsCount,
                  builder: (context, recordsCount, _) {
                    var model = Provider.of<MainScreenModel>(context, listen: false);
                    if (model.isProcedureRecordsEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text('Dnes nebyl přidán žádný záznam.'),
                      );
                    }

                    return ListView.separated(
                      itemCount: model.procedureRecordsCount,
                      separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        var record = model.getProcedureRecordAt(index);
                        return ChangeNotifierProvider(
                          key: ValueKey(record.id),
                          create: (context) => ProcedureRecordItemWidgetModel(record, index == 0),
                          child: ProcedureRecordItemWidget(
                            const EdgeInsets.symmetric(horizontal: 15),
                            true
                          ),
                        );
                      },
                    );
                  }),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<MainScreenModel>(
          builder: (_, model, child) {
            if (model.lastProcedureRecord != null && model.lastProcedureRecord.state == ProcedureRecordState.closed) {
              return Container(width: 0, height: 0);
            }
            return FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Color(0xff34495e),
              onPressed: () async {
                var newProcedureRecord = await Navigator.pushNamed(context, AddProcedureRecordScreen.routeName, arguments: model.lastProcedureRecord);
                if (newProcedureRecord != null) {
                  model.addProcedureRecord(newProcedureRecord);
                }
              },
            );
          }
      ),
    );
  }
}