import 'package:flutter/material.dart';
import 'dart:async';


class AnimatedReplacement<T> extends StatefulWidget {

  final Widget Function(dynamic value) builder;
  final Stream<T> stream;
  final T initialValue;


  const AnimatedReplacement({
    Key key,
    @required this.builder,
    @required this.stream,
    @required this.initialValue
  }) : super(key: key);


  @override
  _AnimatedReplacementState createState() => _AnimatedReplacementState<T>();
}




class _AnimatedReplacementState<T> extends State<AnimatedReplacement>
    with SingleTickerProviderStateMixin {


  AnimationController _animController;
  Animation<double> _animation;

  StreamSubscription<T> _subscription;

  T _value;


  @override
  void initState() {
    super.initState();

    _value = widget.initialValue;

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<double>(
        begin: 1,
        end: 0
    ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeIn
    ));
    _animation.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
        _animController.reverse();
      }
    });

    _subscription = widget.stream.listen((data) {
      _animController.forward();
      _value = data;
    });
  }


  @override
  void dispose() {
    _animController.dispose();
    _subscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.builder(_value),
    );
  }
}