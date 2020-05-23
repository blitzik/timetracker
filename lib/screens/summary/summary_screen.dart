import 'package:app/screens/summary/summary_screen_model.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/extensions/string_extension.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app/app_state.dart';
import 'package:intl/intl.dart';


class SummaryScreen extends StatelessWidget {
  static const routeName = '/summaryCurrent';
  static const archiveRouteName = '/archiveSummary';


  SummaryScreen();

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: Text('Souhrn záznamů'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
                decoration: BoxDecoration(color: Color(0xfff0f0f0), border: Border(bottom: BorderSide(width: 1, color: Color(0xffcccccc)))),
                padding: EdgeInsets.symmetric(vertical: 15),
                child: InkWell(
                  child: Consumer<SummaryScreenModel>(
                    builder: (context, model, _) => createTitle(model)
                  ),
                  onTap: () {
                    var model = Provider.of<SummaryScreenModel>(context, listen: false);
                    model.toggleType();
                  },
                )
            ),

            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Consumer<SummaryScreenModel>(
                    builder: (context, model, _) => RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 15, color: Color(0xff333333)),
                        children: <TextSpan>[
                          TextSpan(text: 'Celkem odpracováno: '),
                          TextSpan(text: '${model.workedHours}h', style: TextStyle(fontWeight: FontWeight.bold)),
                        ]
                      ),
                    )
                  )
              ),
            ),

            Divider(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Consumer<SummaryScreenModel>(
                    builder: (context, model, _) {
                      if (model.isSummaryEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text('Dnes nebyl přidán žádný záznam.'),
                        );
                      }

                      return ListView.separated(
                        separatorBuilder: (BuildContext context, int index) => Divider(),
                        itemCount: model.summaryCount,
                        itemBuilder: (BuildContext context, int index) {
                          var summary = model.getProcedureSummaryAt(index);
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                            title: Text(summary.name,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            subtitle: Text('${summary.quantity}ks     ${summary.timeSpent}h'),
                          );
                        },
                      );
                    }),
              ),
            )
          ],
        )
    );
  }

  Widget createTitle(SummaryScreenModel model) {
    if (model.currentType == SummaryType.day) {
      return ListTile(
        title: Text(
          '${DateFormat('EEEE d. MMMM yyyy').format(model.date).toString().capitalizeFirst()}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${model.date.getWeek()}. týden'),
      );
    }

    return ListTile(
      title: Text(
        '${model.date.getWeek()}. týden',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${DateFormat('d. MMMM yyyy').format(model.date.weekStart()).toString()} - ${DateFormat('d. MMMM yyyy').format(model.date.weekEnd()).toString()}'),
    );
  }
}