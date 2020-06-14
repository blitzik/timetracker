import 'package:app/widgets/procedure_item_widget/procedure_item_widget_bloc.dart';
import 'package:app/screens/actions_overview/actions_overview_screen_events.dart';
import 'package:app/screens/actions_overview/actions_overview_screen_states.dart';
import 'package:app/screens/actions_overview/actions_overview_screen_bloc.dart';
import 'package:app/widgets/procedure_item_widget/procedure_item_widget.dart';
import 'package:app/widgets/procedure_form/procedure_form_bloc.dart';
import 'package:app/widgets/procedure_form/procedure_form.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';


class ActionsOverviewScreen extends StatefulWidget {
  static const routeName = '/actionsOverview';


  ActionsOverviewScreen();

  @override
  _ActionsOverviewScreenState createState() => _ActionsOverviewScreenState();
}


class _ActionsOverviewScreenState extends State<ActionsOverviewScreen> {


  ActionsOverviewScreenBloc _bloc;


  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<ActionsOverviewScreenBloc>(context);
    _bloc.add(ActionsOverviewLoaded());
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
        title: Text('Přehled akcí'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: BlocBuilder<ActionsOverviewScreenBloc, ActionsOverviewScreenState>(
          builder: (context, state) {
            if (state is ActionsOverviewLoadFailure) {
              return Center(
                child: Text(state.errorMessage, style: TextStyle(color: Colors.red)),
              );
            }

            if (state is ActionsOverviewLoadInProgress) {
              return Center(
                child: Column(
                  children: <Widget>[
                    Text('Načítám data ...'),
                    SizedBox(height: 25,),
                    CircularProgressIndicator()
                  ],
                ),
              );
            }

            var st = (state as ActionsOverviewLoadSuccess);
            return ListView.separated(
              itemCount: st.procedures.length,
              separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                ProcedureImmutable procedure = st.procedures.elementAt(index);
                return BlocProvider(
                  key: ValueKey(procedure.id),
                  create: (context) => ProcedureItemWidgetBloc(procedure),
                  child: ProcedureItemWidget(),
                );
              }
          );
          },
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Color(0xff34495e),
          onPressed: () async{
            var result = await _openProcedureCreationDialog(context);
            if (result == null) return;
            Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 1),
              content: ListTile(
                title: Text('Akce byla úspěšně vytvořena'),
                trailing: Icon(Icons.done, color: Colors.lightGreen),
              ),
            ));
          },
        ),
      ),
    );
  }

  Future<ResultObject<Procedure>> _openProcedureCreationDialog(BuildContext _context) async{
    return await showDialog(
        context: _context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Nová akce'),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(25),
                child: BlocProvider(
                  create: (context) => ProcedureFormBloc(null),
                  child: ProcedureForm(),
                ),
              )
            ],
          );
        }
    );
  }
}