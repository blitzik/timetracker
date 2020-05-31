import 'package:app/widgets/animated_replacement/animated_replacement.dart';
import 'package:app/screens/summary/summary_screen_model.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/extensions/string_extension.dart';
import 'package:app/widgets/summary/summary.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class SummaryScreen extends StatelessWidget {
  static const routeName = '/summaryCurrent';


  SummaryScreen();


  @override
  Widget build(BuildContext context) {
    var summaryModel = Provider.of<SummaryScreenModel>(context, listen: false);

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
                  child: AnimatedReplacement<SummaryScreenModel>(
                    stream: summaryModel.modelStream,
                    initialValue: summaryModel,
                    duration: Duration(milliseconds: 100),
                    builder: (model) => _createTitle(model),
                  ),
                  onTap: () {
                    if (summaryModel.currentType == SummaryType.day) {
                      summaryModel.loadSummary.add(SummaryType.week);
                    } else {
                      summaryModel.loadSummary.add(SummaryType.day);
                    }
                  },
                )
            ),

            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Celkem odpracováno: ', style: TextStyle(fontSize: 15, color: Color(0xff333333))),
                    SizedBox(
                      width: 70,
                      child: AnimatedReplacement<double>(
                        stream: summaryModel.workedHoursStream,
                        initialValue: 0.0,
                        duration: Duration(milliseconds: 100),
                        builder: (workedHours) => Text('${workedHours}h', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                )
              ),
            ),

            Divider(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Summary(
                  initSummaryType: SummaryType.day,
                  model: summaryModel,
                )
              ),
            )
          ],
        )
    );
  }

  Widget _createTitle(SummaryScreenModel model) {
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