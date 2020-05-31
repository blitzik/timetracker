import 'package:app/screens/archive/archive_screen_model.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/extensions/string_extension.dart';
import 'package:app/screens/summary/summary_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:collection';


class ArchiveScreen extends StatelessWidget {
  static const routeName = '/archive';

  ArchiveScreen();


  @override
  Widget build(BuildContext context) {
    var archiveModel = Provider.of<ArchiveScreenModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Historické záznamy'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        child: _List(
          model: archiveModel
        ),
      ),
    );
  }
}



class _List extends StatefulWidget {

  final ArchiveScreenModel model;

  _List({
    @required this.model
  });


  @override
  _ListState createState() => _ListState();
}


class _ListState extends State<_List> {

  _ListState();


  @override
  void initState() {
    widget.model.init();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.model.daysStream,
      builder: (BuildContext context, AsyncSnapshot<UnmodifiableListView<DateTime>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('Nebyly nalezeny žádné záznamy'),
          );
        }

        var data = snapshot.data;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            var historyDate = data.elementAt(index);
            return InkWell(
              child: Card(
                color: Color(0xffeceff1),
                child: ListTile(
                  title: Text('${DateFormat('EEEE d. MMMM yyyy').format(historyDate).toString().capitalizeFirst()}'),
                  subtitle: Text('${historyDate.getWeek()}. týden'),
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, SummaryScreen.routeName, arguments: historyDate);
              },
            );
          }
        );
      }
    );
  }
}