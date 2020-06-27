import 'package:app/screens/summary/summary_screen_events.dart';
import 'package:app/screens/summary/summary_screen_states.dart';
import 'package:app/screens/summary/summary_screen_bloc.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/extensions/string_extension.dart';
import 'package:app/widgets/summary/summary.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class SummaryScreen extends StatefulWidget {
  static const String routeName = '/summaryCurrent';

  SummaryScreen();

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}


class _SummaryScreenState extends State<SummaryScreen> {

  SummaryScreenBloc _bloc;


  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<SummaryScreenBloc>(context);
    _bloc.add(SummaryScreenLoaded(SummaryType.day));
  }


  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
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
                child: BlocBuilder<SummaryScreenBloc, SummaryScreenState>(
                  builder: (context, state) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _createTitle(state)
                  )
                )
            ),

            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10, right: 15),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Color(0xffcccccc)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Celkem odpracováno: ',
                      style: TextStyle(fontSize: 15, color: Color(0xff333333)),
                      textAlign: TextAlign.right,
                    )
                  ),
                  SizedBox(
                    width: 70,
                    child: Container(
                      child: BlocBuilder<SummaryScreenBloc, SummaryScreenState>(
                        builder: (context, state) => AnimatedSwitcher(
                          transitionBuilder: (Widget widget, Animation<double> animation) {
                            return ScaleTransition(scale: animation, child: widget);
                          },
                          duration: const Duration(milliseconds: 250),
                          child: _createWorkedHours(state),
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: BlocBuilder<SummaryScreenBloc, SummaryScreenState>(
                  builder: (context, state) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Summary(state, key: UniqueKey())
                  )
                ),
              ),
            )
          ],
        )
    );
  }


  Widget _createTitle(SummaryScreenState state) {
    if (state is SummaryScreenLoadInProgress) {
      return Center(
        key: UniqueKey(),
        child: CircularProgressIndicator(),
      );
    }

    var st = (state as SummaryScreenPeriodState);

    Widget content;
    if (st.summaryPeriod == SummaryType.day) {
      content = ListTile(
        title: Text(
          '${DateFormat('EEEE d. MMMM yyyy').format(st.date).toString().capitalizeFirst()}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${st.date.getWeek()}. týden'),
        trailing: Icon(Icons.low_priority, size: 40),
      );
    } else {
      content = ListTile(
        title: Text(
          '${st.date.getWeek()}. týden',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${DateFormat('d. MMMM yyyy')
            .format(st.date.weekStart())
            .toString()} - ${DateFormat('d. MMMM yyyy').format(
            st.date.weekEnd()).toString()}'),
        trailing: Icon(Icons.low_priority, size: 40),
      );
    }

    return InkWell(
      key: UniqueKey(),
      child: content,
      onTap: () {
        if (st.summaryPeriod == SummaryType.day) {
          _bloc.add(SummaryScreenLoaded(SummaryType.week));
        } else {
          _bloc.add(SummaryScreenLoaded(SummaryType.day));
        }
      },
    );
  }


  Widget _createWorkedHours(SummaryScreenState state) {
    if (state is SummaryScreenLoadInProgress ||
        state is SummaryScreenLoadFailure) {
      return SizedBox(key:UniqueKey(), width: 0, height: 0);
    }

    var st = (state as SummaryScreenLoadSuccess);
    return Text(
      '${st.workedHours}h',
      key: UniqueKey(),
      style: TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}