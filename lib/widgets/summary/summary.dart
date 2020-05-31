import 'package:app/screens/summary/summary_screen_model.dart';
import 'package:app/domain/procedure_summary.dart';
import 'package:flutter/material.dart';
import 'dart:collection';


class Summary extends StatefulWidget {

  final SummaryScreenModel model;
  final SummaryType initSummaryType;


  Summary({
    @required this.initSummaryType,
    @required this.model,
  });


  @override
  _SummaryState createState() => _SummaryState();
}


class _SummaryState extends State<Summary> {


  @override
  void initState() {
    widget.model.loadSummary.add(widget.initSummaryType);
    super.initState();
  }


  @override
  void dispose() {

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.model.procedureSummariesStream,
      builder: (BuildContext context, AsyncSnapshot<UnmodifiableListView<ProcedureSummary>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator()
              )
          );
        }

        if (!snapshot.hasData || snapshot.data.isEmpty) {
          return Center(
            //padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text('Dosud nebyl přidán žádný záznam.'),
          );
        }

        var list = snapshot.data;
        return ListView.separated(
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            var summary = list.elementAt(index);
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              title: Text(summary.name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              subtitle: Text('${summary.quantity}ks     ${summary.timeSpent}h'),
            );
          },
        );
      },
    );
  }
}
