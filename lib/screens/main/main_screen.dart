import 'package:app/widgets/procedure_record_item_widget/procedure_record_item_widget_model.dart';
import 'package:app/widgets/procedure_record_item_widget/procedure_record_item_widget.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen.dart';
import 'package:app/widgets/animated_replacement/animated_replacement.dart';
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
import 'dart:collection';


class MainScreen extends StatelessWidget {
  static const routeName = '/';

  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();

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
                subtitle: AnimatedReplacement<double>(
                  stream: screenModel.workedHoursStream,
                  initialValue: 0.0,
                  builder: (workedHours) => Text('Celkem odpracováno: ${workedHours}h'),
                )
              )
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
              child: _List(
                date: DateTime.now(),
                model: screenModel,
                animatedListStateKey: _animatedListKey
              )
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
            screenModel.addProcedureRecord.add(newProcedureRecord);
            if (_animatedListKey.currentState != null) {
              _animatedListKey.currentState.insertItem(0);
            }
          }
        },
      )
    );
  }
}


class _List extends StatefulWidget {

  final DateTime date;
  final MainScreenModel model;
  final GlobalKey<AnimatedListState> animatedListStateKey;


  _List({
    @required this.date,
    @required this.model,
    @required this.animatedListStateKey
  });


  @override
  _ListState createState() => _ListState();
}


class _ListState extends State<_List> {
  @override
  void initState() {
    widget.model.loadProcedureRecords.add(widget.date);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UnmodifiableListView<ProcedureRecord>>(
      stream: widget.model.procedureRecordsStream,
      builder: (BuildContext context, AsyncSnapshot<UnmodifiableListView<ProcedureRecord>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('Dnes nebyl přidán žádný záznam.'),
          );
        }

        var records = snapshot.data;
        return AnimatedList(
          key: widget.animatedListStateKey,
          initialItemCount: records.length,
          itemBuilder: (BuildContext context, int index, Animation<double> animation) {
            var record = records.elementAt(index);
            return _buildItem(context, record, index, animation);
          },
        );
      },
    );
  }


  Widget _buildItem(BuildContext mainContext, ProcedureRecord record, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Provider(
        key: ValueKey(record.id),
        create: (context) => ProcedureRecordItemWidgetModel(
          record,
          index == 0,
          () { widget.model.refreshWorkedHours(); },
          () { widget.model.refreshWorkedHours(); }
        ),
        child: ProcedureRecordItemWidget(
            const EdgeInsets.symmetric(horizontal: 15),
            true,
            (_context) {
              widget.model.deleteLastRecord();
              widget.animatedListStateKey.currentState.removeItem(index, (context, animation) {
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
