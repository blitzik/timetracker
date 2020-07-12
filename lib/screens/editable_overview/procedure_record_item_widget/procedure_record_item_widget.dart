import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_widget_bloc.dart';
import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_events.dart';
import 'package:app/screens/editable_overview/procedure_record_item_widget/procedure_record_item_states.dart';
import 'package:app/widgets/procedure_record_closing_form/procedure_record_closing_form.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form.dart';
import 'package:app/screens/editable_overview/editable_overview_events.dart';
import 'package:app/screens/editable_overview/editable_overview_bloc.dart';
import 'package:app/utils/result_object/animation_utils.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/utils/result_object/dialog_utils.dart';
import 'package:app/utils/result_object/style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ProcedureRecordItemWidget extends StatefulWidget {
  final bool _displayTrailing;
  final EdgeInsetsGeometry _padding;
  final bool _isFirst;


  ProcedureRecordItemWidget(
    this._padding,
    this._isFirst,
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
            color: record.procedureType == ProcedureType.BREAK ? Color(0xffefebe9) : Color(0xffeceff1),
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
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: record.timeSpent == null || record.timeSpent > 0 ? Colors.black54 : Style.COLOR_POMEGRANATE
                        ),
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
        value: 1, child: Row(
          children: <Widget>[
            Icon(Icons.update),
            SizedBox(width: 10),
            Text('Uzavřít'),
          ],
        ))
      );
    }

    if (record.isClosed) {
      list.add(PopupMenuItem(
        value: 2, child: Row(
          children: <Widget>[
            Icon(Icons.restore),
            SizedBox(width: 10),
            Text('Otevřít'),
          ],
        ))
      );
    }

    list.add(PopupMenuItem(
      value: 3,
      child: Row(
        children: <Widget>[
          Icon(Icons.delete),
          SizedBox(width: 10),
          Text('Odstranit'),
        ],
      ),
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
          ProcedureRecordClosingForm(record, widget._isFirst, _context)
        ],
      )
    );
  }


  Future<void> _openProcedureRecordDialog(BuildContext _context) async{
    return await DialogUtils.showCustomGeneralDialog(
      _context,
      AlertDialog(
        contentPadding: EdgeInsets.all(25),
        content: const Text('Skutečně chcete otevřít záznam?'),
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
        content: RichText(
          text: TextSpan(
            text: 'Skutečně chcete ',
            style: TextStyle(color: Colors.black, fontSize: 18),
            children: <TextSpan>[
              TextSpan(text: 'ODSTRANIT ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              TextSpan(text: 'záznam?')
            ]
          ),
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
        title: Text('Úprava záznamu'),
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