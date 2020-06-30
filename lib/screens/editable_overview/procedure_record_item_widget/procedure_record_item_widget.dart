import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_widget_bloc.dart';
import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_events.dart';
import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_states.dart';
import 'package:app/utils/result_object/animation_utils.dart';
import 'package:app/utils/result_object/dialog_utils.dart';
import 'package:app/utils/result_object/time_utils.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:app/screens/editable_overview/editable_overview_events.dart';
import 'package:app/screens/editable_overview/editable_overview_bloc.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ProcedureRecordItemWidget extends StatefulWidget {
  final bool _displayTrailing;
  final EdgeInsetsGeometry _padding;


  ProcedureRecordItemWidget(
    this._padding,
    this._displayTrailing,
  ) : assert(_padding != null),
      assert(_displayTrailing != null);

  @override
  _ProcedureRecordItemWidgetState createState() => _ProcedureRecordItemWidgetState();
}


class _ProcedureRecordItemWidgetState extends State<ProcedureRecordItemWidget> {
  final double _fontSize = 15;

  ProcedureRecordItemWidgetBloc _bloc;


  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<ProcedureRecordItemWidgetBloc>(context);
  }


  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProcedureRecordItemWidgetBloc, ProcedureRecordItemState>(
      builder: (context, state) {
        var record = (state as ProcedureRecordItemDefaultState).record;
        return AnimatedSwitcher(
          transitionBuilder: (child, animation) {
            return AnimationUtils.getUpdateItemAnimation(child, animation);
          },
          duration: const Duration(milliseconds: AnimationUtils.updateItemDurationInMilliseconds),
          child: Card(
            key: ValueKey(record.hashCode),
            color: Color(0xffeceff1),
            child: InkWell(
              child: ListTile(
                contentPadding: widget._padding,
                title: Text(record.procedureName,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)
                ),
                subtitle: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                          '${DateFormat('Hm').format(record.start)} - ${record.finish == null ? '' : DateFormat('Hm').format(record.finish)}',
                          style: TextStyle(fontSize: _fontSize)
                      ),
                    ),
                    Expanded(
                      child: Text(
                          record.timeSpent == null
                              ? '-'
                              : '${record.timeSpent.toString()}h',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: _fontSize),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _getQuantityString(record),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: _fontSize),
                      )
                    ),
                  ],
                ),
                trailing: _displayMenu(context, state)
              ),
              onTap: _decideClickability(context, state)
            ),
          ),
        );
      }
    );
  }


  String _getQuantityString(ProcedureRecordImmutable record) {
    if (record.isBreak) {
      return '';
    }

    return record.quantity == null
        ? '-'
        : '${record.quantity.toString()}ks';
  }


  Function() _decideClickability(BuildContext context, ProcedureRecordItemDefaultState state) {
    return () async{
      var result = await _displayEditDialog(context, state);
      if (result == null) return;

      Text text = Text('Položka uložena');
      Icon icon = Icon(Icons.done, color: Colors.lightGreen);

      if (!result.isSuccess) {
        text = Text(result.lastMessage);
        icon = Icon(Icons.done, color: Colors.red);
      }

      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: ListTile(
          title: text,
          trailing: icon,
        ),
      ));
    };
  }


  Widget _displayMenu(BuildContext context, ProcedureRecordItemDefaultState state) {
    var record = state.record;
    if (widget._displayTrailing == false) return null;
    if (!state.isLast) {
      return SizedBox(width: 50, height: 50);
    }

    return PopupMenuButton(
      itemBuilder: (BuildContext context) => _generateMenuItems(record),
      onSelected: (v) async{
        switch (v) {
          case 1: {
            await _closeProcedureRecordDialog(context, record);
            break;
          }
          case 2: {
            await _openProcedureRecordDialog(context);
            break;
          }
          case 3: {
            await _deleteProcedureRecordDialog(context);
            break;
          }
          default:
            {
              return;
            }
        }
      },
    );
  }


  List<PopupMenuEntry<int>> _generateMenuItems(ProcedureRecordImmutable record) {
    List<PopupMenuEntry<int>> list = List();
    if (/*!record.isBreak && */record.isOpened) {
      list.add(PopupMenuItem(
          value: 1, child: Text('Uzavřít'))
      );
    }

    if (record.isClosed) {
      list.add(PopupMenuItem(
          value: 2, child: Text('Otevřít'))
      );
    }

    list.add(PopupMenuItem(
      value: 3,
      child: Text('Odstranit'),
    ));

    return list;
  }


  Future<void> _closeProcedureRecordDialog(BuildContext _context, ProcedureRecordImmutable record) async{
    return await DialogUtils.showCustomGeneralDialog(
      _context,
      SimpleDialog(
        contentPadding: EdgeInsets.all(25),
        title: const Text('Uzavření záznamu'),
        children: <Widget>[
          _ProcedureRecordClosingForm(record, _context)
        ],
      )
    );
  }


  Future<void> _openProcedureRecordDialog(BuildContext _context) async{
    return await DialogUtils.showCustomGeneralDialog(
      _context,
      AlertDialog(
        contentPadding: EdgeInsets.all(25),
        content: SingleChildScrollView(
          child: Text('Skutečně otevřít záznam?'),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ano'),
            onPressed: () {
              _bloc.add(ProcedureRecordOpened());
              Navigator.pop(_context);
            },
          ),
        ],
      )
    );
  }


  Future<void> _deleteProcedureRecordDialog(BuildContext _context) async{
    return await DialogUtils.showCustomGeneralDialog(
      _context,
      AlertDialog(
        contentPadding: EdgeInsets.all(25),
        content: SingleChildScrollView(
          child: Text('Skutečně chcete odstranit záznam?'),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ano'),
            onPressed: () {
              var parentBloc = BlocProvider.of<EditableOverviewBloc>(_context);
              parentBloc.add(LastProcedureRecordDeleted());
              Navigator.pop(context);
            }
          ),
        ],
      )
    );
  }


  Future<ResultObject<void>> _displayEditDialog(BuildContext _context, ProcedureRecordItemDefaultState state) async{
    return await DialogUtils.showCustomGeneralDialog(
      _context,
      SimpleDialog(
        contentPadding: EdgeInsets.all(25),
        title: Text(state.record.procedureName),
        children: <Widget>[
          BlocProvider.value(
            value: _bloc.editFormBloc,
            child: ProcedureRecordEditForm(),
          )
        ],
      )
    );
  }
}



class _ProcedureRecordClosingForm extends StatefulWidget {

  final ProcedureRecordImmutable record;
  final BuildContext originContext;


  _ProcedureRecordClosingForm(this.record, this.originContext);


  @override
  _ProcedureRecordClosingFormState createState() => _ProcedureRecordClosingFormState();
}


class _ProcedureRecordClosingFormState extends State<_ProcedureRecordClosingForm> {
  ProcedureRecordItemWidgetBloc _bloc;
  GlobalKey<FormState> _formKey;
  int _quantity;
  DateTime _finish;
  double _timeSpent = 0.0;


  @override
  void initState() {
    super.initState();

    _formKey = GlobalKey();
    _bloc = BlocProvider.of<ProcedureRecordItemWidgetBloc>(widget.originContext);
  }


  double _calcTime(DateTime start, DateTime finish) {
    int t = (_getCleanDateTime(start, finish).millisecondsSinceEpoch - start.millisecondsSinceEpoch) ~/ 1000;
    return t / 3600;
  }


  DateTime _getCleanDateTime(DateTime defaultTime, DateTime d) {
    return DateTime.utc(defaultTime.year, defaultTime.month, defaultTime.day, d.hour, d.minute, 0, 0, 0);
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: _getFormTopRowContext(widget.record)
          ),

          SizedBox(height: 15),

          Container(
            height: 150,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black)
            ),
            child: TimePickerSpinner(
              isShowSeconds: false,
              is24HourMode: true,
              isForce2Digits: true,
              minutesInterval: 15,
              spacing: 40,
              itemHeight: 50,
              itemWidth: 50,
              time: _getDefaultTime(widget.record),
              onTimeChange: (time) {
                setState(() {
                  _finish = time;
                  _timeSpent = _calcTime(widget.record.start, _finish);
                });
              },
            )
          ),

          RaisedButton(
            child: Text('Uzavřít záznam'),
            onPressed: () {
              if (!_formKey.currentState.validate()) {
                return;
              }
              _formKey.currentState.save();

              _bloc.add(ProcedureRecordClosed(_finish, _quantity));

              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }


  List<Widget> _getFormTopRowContext(ProcedureRecordImmutable record) {
    List<Widget> content = List();

    content.add(
      Expanded(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            '${_timeSpent.toString()} h',
            key: ValueKey(_timeSpent),
            style: TextStyle(fontSize: 18),
          )
        ),
      )
    );

    if (!record.isBreak) {
      content.add(
        Expanded(
          child: TextFormField(
            style: TextStyle(fontSize: 18),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              labelText: 'počet',
            ),
            validator: (s) {
              if (s.isEmpty) {
                return 'Zadejte počet';
              }
              return null;
            },
            onSaved: (val) {
              _quantity = int.parse(val);
            },
          ),
        )
      );
    }

    return content;
  }


  DateTime _getDefaultTime(ProcedureRecordImmutable record) {
    var startTime = record.start;
    var now = _getCleanDateTime(startTime, DateTime.now());
    if (now.isBefore(startTime)) {
      return startTime;
    }

    return TimeUtils.findClosestTime(now, 15);
  }
}
