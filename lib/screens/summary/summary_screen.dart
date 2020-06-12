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
  static const routeName = '/summaryCurrent';

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
                  builder: (context, state) {
                    if (state is SummaryScreenLoadInProgress) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    var st = (state as SummaryScreenPeriodState);
                    return InkWell(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _createTitle(state)
                      ),
                      onTap: () {
                        if (st.summaryPeriod == SummaryType.day) {
                          _bloc.add(SummaryScreenLoaded(SummaryType.week));
                        } else {
                          _bloc.add(SummaryScreenLoaded(SummaryType.day));
                        }
                      },
                    );
                  }
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
                      child: BlocBuilder<SummaryScreenBloc, SummaryScreenState>(
                        builder: (context, state) {
                          if (state is SummaryScreenLoadInProgress ||
                              state is SummaryScreenLoadFailure) {
                            return SizedBox(width: 0, height: 0);
                          }

                          var st = (state as SummaryScreenLoadSuccess);
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text('${st.workedHours}h', key: ValueKey(st.workedHours), style: TextStyle(fontWeight: FontWeight.bold))
                          );
                        }
                      ),
                    ),
                  ],
                )
              ),
            ),

            Divider(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                child: BlocBuilder<SummaryScreenBloc, SummaryScreenState>(
                  builder: (context, state) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Summary(state, key: UniqueKey())
                  )
                )
              ),
            )
          ],
        )
    );
  }


  Widget _createTitle(SummaryScreenPeriodState state) {
    if (state.summaryPeriod == SummaryType.day) {
      return ListTile(
        key: UniqueKey(),
        title: Text(
          '${DateFormat('EEEE d. MMMM yyyy').format(state.date).toString().capitalizeFirst()}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${state.date.getWeek()}. týden'),
      );
    }

    return ListTile(
      key: UniqueKey(),
      title: Text(
        '${state.date.getWeek()}. týden',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${DateFormat('d. MMMM yyyy').format(state.date.weekStart()).toString()} - ${DateFormat('d. MMMM yyyy').format(state.date.weekEnd()).toString()}'),
    );
  }
}