import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_widget_bloc.dart';
import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_widget.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen.dart';
import 'package:app/screens/editable_overview/editable_overview_states.dart';
import 'package:app/screens/editable_overview/editable_overview_events.dart';
import 'package:app/screens/editable_overview/editable_overview_bloc.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/extensions/string_extension.dart';
import 'package:app/screens/summary/summary_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class EditableOverview extends StatefulWidget {
  static const String routeName = '/editableOverview';


  EditableOverview();


  @override
  _EditableOverview createState() => _EditableOverview();
}


class _EditableOverview extends State<EditableOverview> {
  GlobalKey<AnimatedListState> _animatedListKey;
  EditableOverviewBloc _bloc;


  @override
  void initState() {
    super.initState();
    _animatedListKey = GlobalKey();
    _bloc = BlocProvider.of<EditableOverviewBloc>(context);
    _bloc.add(ProcedureRecordsLoaded());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_bloc.state.date.getWeek()}. týden'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              decoration: BoxDecoration(color: Color(0xfff0f0f0), border: Border(bottom: BorderSide(width: 1, color: Color(0xffcccccc)))),
              child: FlatButton(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: ListTile(
                  title: Text(
                    '${DateFormat('EEEE d. MMMM yyyy').format(_bloc.state.date).toString().capitalizeFirst()}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      BlocBuilder<EditableOverviewBloc, ProcedureRecordsState>(
                        builder: (context, state) {
                          return Row(
                            children: <Widget>[
                              Text('Celkem odpracováno: '),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return ScaleTransition(scale: animation, child: child);
                                },
                                child: _buildWorkedHours(context, state)
                              )
                            ],
                          );
                        }
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right, size: 40)
                ),
                onPressed: () {
                  Navigator.pushNamed(context, SummaryScreen.routeName, arguments: _bloc.state.date);
                },
              )
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
              child: BlocBuilder<EditableOverviewBloc, ProcedureRecordsState>(
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
                      child: Text('Nebyl přidán žádný záznam.'),
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
      floatingActionButton: BlocConsumer<EditableOverviewBloc, ProcedureRecordsState>(
        listener: (_context, state) {
          if (state is ProcedureRecordAddedSuccess) {
            if (_animatedListKey.currentState != null) {
              _animatedListKey.currentState.insertItem(0);
              _showSnackBar(_context, 'Záznam byl úspěšně uložen.', Icons.check, Colors.green);
            }
          }
          if (state is ProcedureRecordDeletedSuccess) {
            if (_animatedListKey.currentState != null) {
              _animatedListKey.currentState.removeItem(0, (context, animation) => _buildItem(context, state.deletedRecord, 0, animation));
              _showSnackBar(_context, 'Záznam byl úspěšně odstraněn.', Icons.check, Colors.green);
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
              var insertionState = await Navigator.pushNamed(context, AddProcedureRecordScreen.routeName, arguments: st.lastProcedureRecord);
              if (insertionState != null) {
                _bloc.add(ProcedureRecordAdded(insertionState));
              }
            },
          );
        },
      )
    );
  }


  Widget _buildItem(BuildContext mainContext, ProcedureRecordImmutable record, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: BlocProvider(
        key: ValueKey(record.hashCode),
        create: (context) => ProcedureRecordItemWidgetBloc(_bloc, record, index == 0),
        child: ProcedureRecordItemWidget(
            const EdgeInsets.symmetric(horizontal: 15),
            true
        ),
      ),
    );
  }


  Widget _buildWorkedHours(BuildContext context, ProcedureRecordsState state) {
    if (state is ProcedureRecordsLoadInProgress) {
      return SizedBox(
        width: 15,
        height: 15,
        child: CircularProgressIndicator(key: UniqueKey()),
      );
    }

    if (state is ProcedureRecordsLoadingFailure) {
      return Text('-', key: UniqueKey());
    }

    var st = (state as ProcedureRecordsLoadSuccess);
    return Text('${st.workedHours}h', key: ValueKey(st.workedHours));
  }


  void _showSnackBar(BuildContext context, String text, IconData icon, Color color) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: ListTile(
        title: Text(text),
        trailing: Icon(icon, color: color),
      ),
      duration: const Duration(seconds: 1),
    ));
  }


  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
