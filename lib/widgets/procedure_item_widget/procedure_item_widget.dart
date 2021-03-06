import 'package:app/widgets/procedure_item_widget/procedure_item_widget_states.dart';
import 'package:app/widgets/procedure_item_widget/procedure_item_widget_bloc.dart';
import 'package:app/widgets/procedure_form/procedure_form.dart';
import 'package:app/utils/result_object/animation_utils.dart';
import 'package:app/utils/result_object/dialog_utils.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/domain/procedure.dart';
import 'package:flutter/material.dart';


class ProcedureItemWidget extends StatefulWidget {

  final int index;

  ProcedureItemWidget(this.index);

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
      duration: const Duration(milliseconds: AnimationUtils.updateItemDurationInMilliseconds),
      transitionBuilder: (child, animation) {
        return AnimationUtils.getUpdateItemAnimation(child, animation);
      },
      child: Card(
        key: ValueKey(procedure.hashCode),
        color: Color(0xffeceff1),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: ListTile(
            title: Row(
              children: <Widget>[
                SizedBox(
                  width: 50,
                  child: Text('${widget.index}.', style: TextStyle(fontSize: 12)),
                ),
                Expanded(
                  child: Text(procedure.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            trailing: procedure.type == ProcedureType.BREAK ? null : Icon(Icons.edit),
          )
        ),
      ),
    );
  }


  Future<ProcedureImmutable> _openEditDialog(BuildContext _context) async{
    return await DialogUtils.showCustomGeneralDialog(
      _context,
      SimpleDialog(
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
      )
    );
  }
}