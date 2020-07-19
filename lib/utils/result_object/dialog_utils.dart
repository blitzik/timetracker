import 'package:flutter/material.dart';


class DialogUtils {
  static Future<T> showCustomGeneralDialog<T>(BuildContext _context, Widget dialog, [bool barrierDismissible = true]) async{
    return showGeneralDialog(
        context: _context,
        pageBuilder: (BuildContext context, Animation<double> a1, Animation<double> a2) {
          return dialog;
        },
        transitionDuration: Duration(milliseconds: 350),
        transitionBuilder: (BuildContext context, Animation<double> a1, Animation<double> a2, Widget child) {
          return SlideTransition(
              child: child,
              position: Tween<Offset>(
                  begin: Offset(-1, 0),
                  end: Offset(0, 0)
              ).animate(
                  CurvedAnimation(curve: Curves.easeInExpo, parent: a1)
              )
          );
        },
        barrierDismissible: barrierDismissible,
        barrierLabel: '',
        barrierColor: Colors.black54
    );
  }
}