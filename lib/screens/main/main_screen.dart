import 'package:app/widgets/animated_replacement/animated_replacement.dart';
import 'package:app/widgets/procedure_record_item_widget/procedure_record_item_widget_model.dart';
import 'package:app/widgets/procedure_record_item_widget/procedure_record_item_widget.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen.dart';
import 'package:app/screens/actions_overview/actions_overview_screen.dart';
import 'package:app/screens/archive/archive_screen.dart';
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

  final GlobalKey<AnimatedListState> _animatedList = GlobalKey();

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
                child: Text('TimeTracker', style: TextStyle(color: Colors.white, fontSize: 16)),
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

            ListTile(
              title: Text('Historické záznamy'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, ArchiveScreen.routeName);
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
                subtitle: AnimatedReplacement(
                  stream: screenModel.ownStream,
                  initialValue: screenModel,
                  builder: (value) => Text('Celkem odpracováno: ${value.workedHours}h'),
                )
              )
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
              child: StreamBuilder<MainScreenModel>(
                stream: screenModel.ownStream,
                builder: (context, snapshot) {
                  var model = Provider.of<MainScreenModel>(context, listen: false);
                  if (model.isProcedureRecordsEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text('Dnes nebyl přidán žádný záznam.'),
                    );
                  }

                  // todo for some reason AnimatedList rebuilds all items when we navigate to another screen
                  return AnimatedList(
                    key: _animatedList,
                    initialItemCount: model.procedureRecordsCount,
                    itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                      var record = model.getProcedureRecordAt(index);
                      return _buildItem(context, record, index, animation);
                    },
                  );
                }
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xff34495e),
        onPressed: () async {
          var newProcedureRecord = await Navigator.pushNamed(context, AddProcedureRecordScreen.routeName, arguments: screenModel.lastProcedureRecord);
          if (newProcedureRecord != null) {
            screenModel.addProcedureRecord(newProcedureRecord);
            if (_animatedList.currentState != null) {
              _animatedList.currentState.insertItem(0);
            }
          }
        },
      )
    );
  }


  Widget _buildItem(BuildContext mainContext, ProcedureRecord record, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Provider(
        key: ValueKey(record.id),
        create: (context) => ProcedureRecordItemWidgetModel(record, index == 0),
        child: ProcedureRecordItemWidget(
            const EdgeInsets.symmetric(horizontal: 15),
            true,
            (_context) {
              var screenModel = Provider.of<MainScreenModel>(mainContext, listen: false);
              screenModel.deleteLastRecord();
              _animatedList.currentState.removeItem(index, (context, animation) {
                return _buildItem(mainContext, record, index, animation);
              }
              );
              Navigator.pop(_context);
            }
        ),
        dispose: (context, model) => model.dispose(),
      ),
    );
  }
}