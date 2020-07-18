import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_widget_bloc.dart';
import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_events.dart';
import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_widget.dart';
import 'package:app/widgets/procedure_record_creation_form/procedure_record_creation_form_bloc.dart';
import 'package:app/widgets/procedure_record_closing_form/procedure_record_closing_form_bloc.dart';
import 'package:app/widgets/procedure_record_creation_form/procedure_record_creation_form.dart';
import 'package:app/widgets/procedure_record_closing_form/procedure_record_closing_form.dart';
import 'package:app/screens/editable_overview/editable_overview_states.dart';
import 'package:app/screens/editable_overview/editable_overview_events.dart';
import 'package:app/screens/editable_overview/editable_overview_bloc.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/utils/result_object/dialog_utils.dart';
import 'package:app/screens/summary/summary_screen.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/extensions/string_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:app/app_bloc.dart';
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
  AppBloc _appBloc;

  Map<int, ProcedureRecordItemWidgetBloc> _itemsBlocs;


  @override
  void initState() {
    super.initState();

    _animatedListKey = GlobalKey();

    _appBloc = BlocProvider.of<AppBloc>(context);
    _bloc = BlocProvider.of<EditableOverviewBloc>(context);
    _bloc.add(ProcedureRecordsLoaded());

    _itemsBlocs = Map();
  }


  @override
  void dispose() {
    _itemsBlocs.forEach((key, value) {
      value.dispose();
    });

    _bloc.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<EditableOverviewBloc, ProcedureRecordsState>(
      listener: (_context, state) {
        if (state is ProcedureRecordAddedSuccess) {
          if (_animatedListKey.currentState != null) {
            _animatedListKey.currentState.insertItem(0);
          }
        }
        if (state is ProcedureRecordDeletedSuccess) {
          if (_animatedListKey.currentState != null) {
            _animatedListKey.currentState.removeItem(0, (context, animation) => _buildItem(context, state.deletedRecord, state.records.length, 0, animation));
            _itemsBlocs[state.deletedRecord.id].dispose();
            _itemsBlocs.remove(state.deletedRecord.id);
          }
        }
      },

      child: Scaffold(
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
                        return _buildItem(context, record, records.length, index, animation);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: BlocBuilder<EditableOverviewBloc, ProcedureRecordsState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _buildFloatingButton(state)
            );
          },
        )
      ),
    );
  }


  Widget _buildFloatingButton(ProcedureRecordsState state) {
    if (state is ProcedureRecordsLoadInProgress ||
        state is ProcedureRecordsLoadingFailure) {
      return SizedBox(key: UniqueKey());
    }

    var st = (state as ProcedureRecordsLoadSuccess);
    if (st.lastProcedureRecord != null && st.lastProcedureRecord.isOpened) {
      return FloatingActionButton(
        key: UniqueKey(),
        child: Icon(Icons.update),
        backgroundColor: Color(0xff34495e),
        onPressed: () async{
          var closedRecord = await _displayCloseProcedureRecordDialog(context, st.lastProcedureRecord, st.records.length == 1);
          if (closedRecord != null) {
            _itemsBlocs[closedRecord.id].add(ProcedureRecordClosed(closedRecord));
          }
        },
      );
    }

    return FloatingActionButton(
      key: UniqueKey(),
      child: Icon(Icons.add),
      backgroundColor: Color(0xff34495e),
      onPressed: () async{
        var newRecord = await _displayCreateProcedureRecordDialog(context, st.lastProcedureRecord);
        if (newRecord != null) {
          _bloc.add(ProcedureRecordAdded(newRecord));
        }
      },
    );
  }


  Widget _buildItem(BuildContext mainContext, ProcedureRecordImmutable record, int recordsCount, int index, Animation<double> animation) {
    if (!_itemsBlocs.containsKey(record.id)) {
      _itemsBlocs[record.id] = ProcedureRecordItemWidgetBloc(_bloc, record, _appBloc);
    }

    return SizeTransition(
      key: ValueKey(record.id),
      sizeFactor: animation,
      child: BlocProvider.value(
        value: _itemsBlocs[record.id],
        child: ProcedureRecordItemWidget(
          const EdgeInsets.symmetric(horizontal: 15),
          index == recordsCount - 1,
          index == 0,
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


  Future<ProcedureRecordImmutable> _displayCloseProcedureRecordDialog(BuildContext _context, ProcedureRecordImmutable record, bool isFirstRecordOfDay) async{
    return await DialogUtils.showCustomGeneralDialog(
        _context,
        SimpleDialog(
          contentPadding: EdgeInsets.all(25),
          title: const Text('Uzavření záznamu'),
          children: <Widget>[
            BlocProvider(
              create: (context) => ProcedureRecordClosingFormBloc(record, isFirstRecordOfDay),
              child: ProcedureRecordClosingForm(),
            )
          ],
        )
    );
  }


  Future<ProcedureRecordImmutable> _displayCreateProcedureRecordDialog(BuildContext _context, ProcedureRecordImmutable lastRecord) async{
    return await showModalBottomSheet(
      context: context,
      barrierColor: Colors.black38,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => ProcedureRecordCreationFormBloc(
            (_appBloc.state as AppLoadSuccess).procedures,
            lastRecord
          ),
          child: ProcedureRecordCreationForm(),
        );
      }
    );
  }
}
