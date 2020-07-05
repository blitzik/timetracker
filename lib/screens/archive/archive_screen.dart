import 'package:app/screens/editable_overview/editable_overview.dart';
import 'package:app/screens/archive/archive_screen_events.dart';
import 'package:app/screens/archive/archive_screen_states.dart';
import 'package:app/screens/archive/archive_screen_bloc.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/extensions/string_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ArchiveScreen extends StatelessWidget {
  static const String routeName = '/archive';

  ArchiveScreen();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historické záznamy'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        child: _List(),
      ),
    );
  }
}



class _List extends StatefulWidget {

  @override
  _ListState createState() => _ListState();
}


class _ListState extends State<_List> {

  ScrollController _scrollController;
  ArchiveScreenBloc _bloc;
  int _scrollThreshold = 200;


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (maxScroll - currentScroll <= _scrollThreshold) {
        _bloc.add(FetchSummary());
      }
    });

    _bloc = BlocProvider.of<ArchiveScreenBloc>(context);
    _bloc.add(FetchSummary());
  }


  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArchiveScreenBloc, ArchiveScreenState>(
      builder: (context, state) {
        if (state is ArchiveScreenLoadInProgress || state is ArchiveUninitialized) {
          return Center(
            child: Column(
              children: <Widget>[
                Text('Načítám data...'),
                CircularProgressIndicator(),
              ],
            ),
          );
        }

        if (state is ArchiveScreenLoadFailure) {
          return Center(
            child: ListTile(
              title: Text(state.errorMessage, style: TextStyle(color: Colors.red)),
              trailing: Icon(Icons.error, color: Colors.red),
            ),
          );
        }

        var st = (state as ArchiveScreenLoadSuccessful);
        if (st.days.isEmpty) {
          return Center(
            child: Text('Nebyly nalezeny žádné záznamy.'),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: st.days.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == st.days.length) {
              if (st.hasReachedMax) {
                return SizedBox(width: 0, height: 0);
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: SizedBox(width: 25, height:25, child: CircularProgressIndicator())
                )
              );
            }

            var historyDate = st.days.elementAt(index);
            return InkWell(
              child: Card(
                color: Color(0xffeceff1),
                child: ListTile(
                  title: Text('${DateFormat('EEEE d. MMMM yyyy').format(historyDate).toString().capitalizeFirst()}'),
                  subtitle: Text('${historyDate.getWeek()}. týden'),
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, EditableOverview.routeName, arguments: historyDate);
              },
            );
          }
        );
      }
    );
  }
}