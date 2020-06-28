import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';


class AnimationUtils {
  static const int updateItemDurationInMilliseconds = 1000;
  static AnimatedWidget getUpdateItemAnimation(Widget child, Animation<double> parent) {
    return SlideTransition(
        child: child,
        position: Tween<Offset>(
            begin: Offset(-1, 0.25),
            end: Offset(0, 0)
        ).animate(
            CurvedAnimation(curve: Curves.elasticInOut, parent: parent)
        )
    );
  }
}