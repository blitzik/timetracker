import 'package:app/widgets/procedure_item_widget/procedure_item_widget_bloc.dart';
import 'package:app/screens/actions_overview/actions_overview_screen_states.dart';
import 'package:app/screens/actions_overview/actions_overview_screen_bloc.dart';
import 'package:app/widgets/procedure_item_widget/procedure_item_widget.dart';
import 'package:app/widgets/procedure_form/procedure_form.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:app/app_bloc.dart';


class ActionsOverviewScreen extends StatefulWidget {
  static const String routeName = '/actionsOverview';


  ActionsOverviewScreen();

  @override
  _ActionsOverviewScreenState createState() => _ActionsOverviewScreenState();
}


class _ActionsOverviewScreenState extends State<ActionsOverviewScreen> {

  GlobalKey<AnimatedListState> _animatedListKey;
  ActionsOverviewScreenBloc _bloc;
  AppBloc _appBloc;


  @override
  void initState() {
    super.initState();
    _animatedListKey = GlobalKey();
    _appBloc = BlocProvider.of<AppBloc>(context);
    _bloc = BlocProvider.of<ActionsOverviewScreenBloc>(context);
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
        padding: const EdgeInsets.all(5),
        child: BlocConsumer<ActionsOverviewScreenBloc, ActionsOverviewScreenState>(
          listener: (_context, state) {
            if (state is ActionsOverviewProcedureSaveFailure) {
              _showSnackBar(_context, state.errorMessage, Icons.error, Colors.red);
            }
            if (state is ActionsOverviewProcedureSaveSuccess) {
              if (_animatedListKey.currentState != null) {
                _animatedListKey.currentState.insertItem(0);
              }
              _showSnackBar(_context, 'Akce byla úspěšně přidána', Icons.check, Colors.green);
            }
          },
          buildWhen: (oldState, newState) {
            return !(newState is ActionsOverviewProcedureSaveFailure);
          },
          builder: (context, state) {
            if (state is ActionsOverviewLoadFailure) {
              return Center(
                child: Text(state.errorMessage, style: TextStyle(color: Colors.red)),
              );
            }

            var st = (state as ActionsOverviewLoadSuccess);
            return AnimatedList(
              key: _animatedListKey,
              initialItemCount: st.procedures.length,
              itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                ProcedureImmutable procedure = st.procedures.elementAt(index);
                return _buildItem(procedure, animation);
              }
          );
          },
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Color(0xff34495e),
          onPressed: () => _openProcedureCreationDialog(context),
        ),
      ),
    );
  }


  Widget _buildItem(ProcedureImmutable procedure, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: BlocProvider(
        key: ValueKey(procedure.id),
        create: (context) => ProcedureItemWidgetBloc(procedure, _appBloc),
        child: ProcedureItemWidget(),
      ),
    );
  }


  Future<ResultObject<ProcedureImmutable>> _openProcedureCreationDialog(BuildContext _context) async{
    return await showDialog(
        context: _context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Nová akce'),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(25),
                child: BlocProvider.value(
                  value: _bloc.creationFormBloc,
                  child: ProcedureForm(),
                ),
              )
            ],
          );
        }
    );
  }


  void _showSnackBar(BuildContext context, String text, IconData icon, Color color) {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: ListTile(
        title: Text(text),
        trailing: Icon(icon, color: color),
      ),
    ));
  }
}