import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter/material.dart';


typedef TimePickerSelectionChanged = void Function(DateTime time);


class TimePicker extends StatefulWidget {

  final DateTime time;
  final List<int> hours;
  final List<int> minutes;
  final TimePickerSelectionChanged onTimeChanged;


  TimePicker({
    Key key,
    this.time,
    @required this.hours,
    @required this.minutes,
    @required this.onTimeChanged
  }) : assert(hours != null),
        assert(minutes != null),
        assert(onTimeChanged != null),
        super(key: key);


  @override
  _TimePickerState createState() => _TimePickerState();
}


class _TimePickerState extends State<TimePicker> {

  int _hour;
  int _minute;

  SwiperController _hourController = SwiperController();
  SwiperController _minuteController = SwiperController();


  @override
  void initState() {
    super.initState();

    if (widget.time == null) {
      DateTime now = DateTime.now();
      _hour = now.hour;
      _minute = now.minute;

    } else {
      _hour = widget.time.hour;
      _minute = widget.time.minute;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 50,
            child: Swiper(
              controller: _hourController,
              index: widget.hours.indexWhere((element) => _hour == element),
              itemCount: widget.hours.length,
              scale: -0.2,
              scrollDirection: Axis.vertical,
              viewportFraction: 0.4,
              itemBuilder: (context, index) {
                return Center(child: Text(widget.hours[index].toString().padLeft(2, '0'), style: TextStyle(fontSize: 18)));
              },
              onIndexChanged: (index) {
                _hour = widget.hours[index];
                if (_hour == 0) {
                  _minuteController.move(0);
                }

                var now = DateTime.now();
                var selectedTime = DateTime(now.year, now.month, now.day, widget.hours[index], _minute, 0, 0, 0);
                widget.onTimeChanged(selectedTime);
              },
            ),
          ),

          SizedBox(
            width: 15,
            child: Center(
              child: Text(':', style: TextStyle(fontSize: 18)),
            ),
          ),

          SizedBox(
            width: 50,
            child: Swiper(
              controller: _minuteController,
              index: widget.minutes.indexWhere((element) => _minute == element),
              itemCount: widget.minutes.length,
              scale: -0.2,
              scrollDirection: Axis.vertical,
              viewportFraction: 0.4,
              physics: _hour == 0 ? NeverScrollableScrollPhysics() : null,
              itemBuilder: (context, index) {
                return Center(child: Text(widget.minutes[index].toString().padLeft(2, '0'), style: TextStyle(fontSize: 18)));
              },
              onIndexChanged: (index) {
                _minute = widget.minutes[index];

                var now = DateTime.now();
                var selectedTime = DateTime(now.year, now.month, now.day, _hour, widget.minutes[index], 0, 0, 0);
                widget.onTimeChanged(selectedTime);
              },
            ),
          )
        ],
      ),
    );
  }
}
