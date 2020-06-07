import 'package:app/widgets/procedure_record_item_widget/procedure_record_item_widget_model.dart';
import 'package:app/widgets/procedure_record_item_widget/procedure_record_item_widget.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen.dart';
import 'package:app/screens/actions_overview/actions_overview_screen.dart';
import 'package:app/screens/main/main_screen_states.dart';
import 'package:app/screens/main/main_screen_events.dart';
import 'package:app/screens/archive/archive_screen.dart';
import 'package:app/screens/summary/summary_screen.dart';
import 'package:app/screens/main/main_screen_bloc.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/extensions/string_extension.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app/app_bloc.dart';
import 'package:intl/intl.dart';


class MainScreen extends StatefulWidget {
  static const routeName = '/';

  MainScreen();


  @override
  _MainScreenState createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {
  GlobalKey<AnimatedListState> _animatedListKey;
  MainScreenBloc _mainBloc;


  @override
  void initState() {
    super.initState();
    _mainBloc = BlocProvider.of<MainScreenBloc>(context);
    _mainBloc.add(ProcedureRecordsLoaded(BlocProvider.of<AppBloc>(context).state.date));
    _animatedListKey = GlobalKey();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) => Scaffold(
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
                title: Text('Dnešní souhrn záznamů'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, SummaryScreen.routeName, arguments: DateTime.now());
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
        body: BlocListener<MainScreenBloc, ProcedureRecordsState>(
          listener: (context, state) {
            if (state is RecordAddedSuccess) {
              if (_animatedListKey.currentState != null) {
                _animatedListKey.currentState.insertItem(0);
              }
            }
          },
          child: Column(
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
                    subtitle: BlocBuilder<MainScreenBloc, ProcedureRecordsState>(
                      builder: (context, state) {
                        if (state is ProcedureRecordsLoadInProgress) {
                          return CircularProgressIndicator();
                        }

                        if (state is ProcedureRecordsLoadingFailure) {
                          return Text('-');
                        }

                        var st = (state as ProcedureRecordsLoadSuccess);
                        return Text('Celkem odpracováno: ${st.workedHours}h');
                      }
                    )
                  )
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
                  child: BlocBuilder<MainScreenBloc, ProcedureRecordsState>(
                    builder: (BuildContext context, state) {
                      if (state is ProcedureRecordsLoadInProgress) {
                        return Center(
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state is ProcedureRecordsLoadingFailure) {
                        return Text(state.message);
                      }

                      var st = (state as ProcedureRecordsLoadSuccess);
                      if (st.records.isEmpty) {
                        return Center(
                          child: Text('Dnes nebyl přidán žádný záznam.'),
                        );
                      }

                      var records = st.records;
                      return AnimatedList(
                        key: _animatedListKey,
                        initialItemCount: records.length,
                        itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                          var record = records.elementAt(index);
                          return _buildItem(context, record, index, animation);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: BlocConsumer<MainScreenBloc, ProcedureRecordsState>(
          listener: (oldState, newState) {
            if (newState is RecordAddedSuccess) {
              if (_animatedListKey.currentState != null) {
                _animatedListKey.currentState.insertItem(0);
              }
            }
          },
          builder: (context, state) {
            if (state is ProcedureRecordsLoadInProgress) {
              return Container(height: 0, width: 0);
            }

            if (state is ProcedureRecordsLoadingFailure) {
              return Container(height: 0, width: 0);
            }

            var st = (state as ProcedureRecordsLoadSuccess);
            return FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Color(0xff34495e),
              onPressed: () async{
                var newProcedureRecord = await Navigator.pushNamed(context, AddProcedureRecordScreen.routeName, arguments: st.lastProcedureRecord);
                if (newProcedureRecord != null) {
                  _mainBloc.add(ProcedureRecordAdded(newProcedureRecord));
                }
              },
            );
          },
        )
      ),
    );
  }


  Widget _buildItem(BuildContext mainContext, ProcedureRecord record, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Provider(
        key: ValueKey(record.id),
        create: (context) => ProcedureRecordItemWidgetModel(
            record,
            index == 0
        ),
        child: ProcedureRecordItemWidget(
            const EdgeInsets.symmetric(horizontal: 15),
            true,
                (_context) {
              /*widget.model.deleteLastRecord();
              widget.animatedListStateKey.currentState.removeItem(index, (context, animation) {
                return _buildItem(mainContext, record, index, animation);
              }
              );*/
              Navigator.pop(_context);
            }
        ),
        dispose: (context, model) => model.dispose(),
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
    _mainBloc.dispose();
  }
}
