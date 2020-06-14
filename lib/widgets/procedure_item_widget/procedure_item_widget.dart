import 'package:app/widgets/procedure_item_widget/procedure_item_widget_states.dart';
import 'package:app/widgets/procedure_item_widget/procedure_item_widget_bloc.dart';
import 'package:app/widgets/procedure_form/procedure_form.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/material.dart';


class ProcedureItemWidget extends StatefulWidget {

  ProcedureItemWidget();

  @override
  _ProcedureItemWidgetState createState() => _ProcedureItemWidgetState();
}


class _ProcedureItemWidgetState extends State<ProcedureItemWidget> {

  ProcedureItemWidgetBloc _bloc;


  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<ProcedureItemWidgetBloc>(context);
  }


  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProcedureItemWidgetBloc, ProcedureItemState>(
      listenWhen: (oldState, newState) {
        return (newState is ProcedureItemUpdateSuccess ||
                newState is ProcedureItemUpdateFailure);
      },
      listener: (_context, newState) {
        ScaffoldState ss = Scaffold.of(context);
        Text text = Text('Akce byla úspěšně uložena');
        Icon icon = Icon(Icons.done, color: Colors.lightGreen);

        if (newState is ProcedureItemUpdateFailure) {
          text = Text(newState.errorMessage);
          icon = Icon(Icons.error, color: Colors.red);
        }

        ss.showSnackBar(SnackBar(
          duration: const Duration(seconds: 1),
          content: ListTile(
            title: text,
            trailing: icon,
          ),
        ));
      },
      builder: (context, state) {
        ProcedureImmutable procedure = (state as ProcedureItemDefaultState).procedure;
        if (procedure.type == ProcedureType.BREAK) {
          return getBody(procedure);
        }

        return InkWell(
          child: getBody(procedure),
          onTap: () {
            _openEditDialog(context);
          }
        );
      }
    );
  }


  Widget getBody(ProcedureImmutable procedure) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Card(
        key: UniqueKey(),
        color: Color(0xffeceff1),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: ListTile(
            title: Text(procedure.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            trailing: procedure.type == ProcedureType.BREAK ? null : Icon(Icons.edit),
          )
        ),
      ),
    );
  }


  Future<ProcedureImmutable> _openEditDialog(BuildContext _context) async{
    return showDialog(
      context: _context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Úprava záznamu'),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(25),
              child: BlocProvider.value(
                value: _bloc.formBloc,
                child: ProcedureForm(),
              ),
            )
          ],
        );
      }
    );
  }
}