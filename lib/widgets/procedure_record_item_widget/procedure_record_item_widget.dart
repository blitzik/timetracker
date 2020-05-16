import 'package:app/widgets/procedure_record_item_widget/procedure_record_item_widget_model.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
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


  ProcedureRecordItemWidget(
    this._padding,
    this._displayTrailing
  );


  @override
  Widget build(BuildContext context) {
    return Consumer<ProcedureRecordItemWidgetModel>(
        builder: (context, record, _) {
          print('===== ITEM ${record.id} REBUILT =====');
          return ListTile(
          contentPadding: _padding,
          title: Text(record.procedureName,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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
        );
        }
    );
  }


  String _getQuantityString(ProcedureRecordItemWidgetModel record) {
    if (record.procedureId == 1) {
      // break
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

    /*return SizedBox(
        width: 50,
        height: 50,
        child: IconButton(
          icon: Icon(Icons.delete, color: Color(0xff888888)),
          onPressed: _onRemoveClicked
        ),
      );*/

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
              // todo
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
                          mainModel.refresh();

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


  Future<void> _openProcedureRecordDialog(BuildContext _context) async {
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
                    mainModel.refresh();

                    Navigator.pop(_context);
                  },
                ),
              ],
        )
    );
  }
}
