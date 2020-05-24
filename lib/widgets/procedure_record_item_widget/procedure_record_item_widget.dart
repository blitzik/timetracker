import 'package:app/widgets/procedure_record_item_widget/procedure_record_item_widget_model.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_model.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/screens/main/main_screen_model.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ProcedureRecordItemWidget extends StatelessWidget {
  final bool _displayTrailing;
  final EdgeInsetsGeometry _padding;

  final double _fontSize = 15;
  final Animation<double> _animation;

  final Function(BuildContext context) _onDeleteClicked;


  ProcedureRecordItemWidget(
    this._padding,
    this._displayTrailing,
    this._animation,
    this._onDeleteClicked
  ) : assert(_padding != null),
      assert(_displayTrailing != null),
      assert(_animation != null),
      assert(_onDeleteClicked != null);


  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      child: Consumer<ProcedureRecordItemWidgetModel>(
        builder: (context, record, _) {
          print('REBUILT ${record.procedureRecord.id} =====');
          return InkWell(
            child: ListTile(
              contentPadding: _padding,
              title: Text(record.procedureName,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)
              ),
              subtitle: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text(
                        '${DateFormat('Hm').format(record.start)} - ${record.finish == null ? '' : DateFormat('Hm').format(record.finish)}',
                        style: TextStyle(fontSize: _fontSize),
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
                    child: Text(_getQuantityString(record),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: _fontSize),
                    ),
                  ),
                ],
              ),
              trailing: _displayMenu(context, record)
            ),
            onTap: _decideClickability(context, record)
          );
        }
      ),
    );
  }


  Function() _decideClickability(BuildContext context, ProcedureRecordItemWidgetModel record) {
    if (record.isBreak || (record.isLast && record.state == ProcedureRecordState.opened)) return null;
    return () async{
      var result = await _displayEditDialog(context, record);
      if (result == null) return;

      ScaffoldState ss = Scaffold.of(context);
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


  String _getQuantityString(ProcedureRecordItemWidgetModel record) {
    if (record.isBreak) {
      return '';
    }

    return record.quantity == null
        ? ''
        : '${record.quantity.toString()}ks';
  }


  Widget _displayMenu(BuildContext context, ProcedureRecordItemWidgetModel record) {
    if (_displayTrailing == false) return null;
    if (!record.isLast) {
      return SizedBox(width: 50, height: 50);
    }

    return PopupMenuButton(
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
            value: 1, child: _displayToggleStateText(record.state)),
        PopupMenuItem(
          value: 2,
          child: Text('Odstranit'),
        ),
      ],
      onSelected: (v) async{
        switch (v) {
          case 1:
            {
              if (record.state == ProcedureRecordState.opened) {
                await _closeProcedureRecordDialog(context);
              } else {
                await _openProcedureRecordDialog(context);
              }
              break;
            }
          case 2:
            {
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


  Widget _displayToggleStateText(ProcedureRecordState s) {
    if (s == ProcedureRecordState.opened) {
      return Text('Uzavřít');
    }
    return Text('Otevřít');
  }


  Future<void> _closeProcedureRecordDialog(BuildContext _context) async {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    int quantity;
    DateTime finish;
    return await showDialog(
        context: _context,
        builder: (BuildContext context) => SimpleDialog(
              contentPadding: EdgeInsets.all(25),
              title: const Text('Uzavření záznamu'),
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
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
                          quantity = int.parse(val);
                        },
                      ),
                      SizedBox(height: 15),
                      Container(
                          height: 150,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1, color: Colors.black)),
                          child: TimePickerSpinner(
                            isShowSeconds: false,
                            is24HourMode: true,
                            isForce2Digits: true,
                            minutesInterval: 15,
                            spacing: 75,
                            itemHeight: 50,
                            onTimeChange: (time) {
                              finish = time;
                            },
                          )),
                      RaisedButton(
                        child: Text('Uzavřít záznam'),
                        onPressed: () {
                          if (!_formKey.currentState.validate()) {
                            return;
                          }
                          _formKey.currentState.save();

                          var model = Provider.of<ProcedureRecordItemWidgetModel>(_context, listen: false);
                          model.closeRecord(finish, quantity);

                          var mainModel = Provider.of<MainScreenModel>(_context, listen: false);
                          mainModel.refreshWorkedHours();

                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                )
              ],
        )
    );
  }


  Future<void> _openProcedureRecordDialog(BuildContext _context) async{
    return await showDialog(
        context: _context,
        builder: (BuildContext context) => AlertDialog(
          contentPadding: EdgeInsets.all(25),
          content: SingleChildScrollView(
            child: Text('Skutečně otevřít záznam?'),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ano'),
              onPressed: () {
                var model = Provider.of<ProcedureRecordItemWidgetModel>( _context, listen: false);
                model.openRecord();

                var mainModel = Provider.of<MainScreenModel>(_context, listen: false);
                mainModel.refreshWorkedHours();

                Navigator.pop(_context);
              },
            ),
          ],
        )
    );
  }


  Future<void> _deleteProcedureRecordDialog(BuildContext _context) async{
    return await showDialog(
      context: _context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: EdgeInsets.all(25),
        content: SingleChildScrollView(
          child: Text('Skutečně chcete odstranit záznam?'),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ano'),
            onPressed: () {
              _onDeleteClicked?.call(_context);
            }
          ),
        ],
      )
    );
  }


  Future<ResultObject<void>> _displayEditDialog(BuildContext _context, ProcedureRecordItemWidgetModel record) async{
    return showDialog(
        context: _context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(25),
            title: Text(record.procedureName),
            children: <Widget>[
              ChangeNotifierProvider(
                create: (context) => ProcedureRecordEditFormModel(record.procedureRecord, () { record.refresh(); }),
                child: ProcedureRecordEditForm(),
              )
            ],
          );
        }
    );
  }
}
