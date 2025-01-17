import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/locator.dart';
import 'package:plasco/services/web.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../strings.dart';
import '../../inputs/MyText.dart';

class DatePickerWidget extends StatefulWidget {
  DatePickerWidget(
      {Key key,
      this.onPressedYes,
      this.onPressedNo,
      this.onPressedOk,
      this.onPressedCancel})
      : super(key: key);

  final Function onPressedYes;
  final Function onPressedNo;
  final Function onPressedOk;
  final Function onPressedCancel;

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState(
      this.onPressedYes,
      this.onPressedNo,
      this.onPressedOk,
      this.onPressedCancel);
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  _DatePickerWidgetState(this.onPressedYes, this.onPressedNo, this.onPressedOk,
      this.onPressedCancel);

  Function onPressedYes;
  Function onPressedNo;
  Function onPressedOk;
  Function onPressedCancel;
  int selectedRadio;

  Jalali jalali;
  DateTime now;
  MyBloc httpBloc = MyBloc();

  final _dateStreamController = StreamController<Jalali>.broadcast();

  StreamSink<Jalali> get timeSink => _dateStreamController.sink;

  Stream<Jalali> get streamTime => _dateStreamController.stream;

  @override
  void initState() {
    // TODO: implement initState

    httpBloc.stream.listen((event) {
      if (event == null) {
        Navigator.of(context).pop();
      } else {
        now = event;
        jalali = Jalali.fromDateTime(event);
        timeSink.add(jalali);
      }
    });
    Future.delayed(Duration.zero, () {
      locator<Web>().post(GetServerTimeEvent(httpBloc), context);
    });

    super.initState();
  }

  @override
  void dispose() {
    httpBloc.dispose();
    _dateStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: streamTime,
        builder: (context, AsyncSnapshot<Jalali> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    textDirection: TextDirection.rtl,
                    children: [
                      GestureDetector(
                          onTap: () async {
                            var next = jalali.withDay(1).addMonths(1);
                            if (next.monthLength != jalali.monthLength) {
                              if (jalali.day > next.monthLength) {
                                jalali = jalali.copy(day: next.monthLength);
                              }
                            }

                            jalali = jalali.addMonths(1);
                            timeSink.add(jalali);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: ColorPalette.Yellow1,
                                  width: 1,
                                )),
                            child: Icon(
                              Icons.keyboard_arrow_right,
                              color: ColorPalette.Yellow1,
                              size: 24,
                            ),
                          )),
                      MyText(
                        text: jalali.formatter.mN + ' ' + jalali.formatter.yyyy,
                        textAlign: TextAlign.center,
                        color: ColorPalette.Yellow1,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      GestureDetector(
                          onTap: () async {
                            var previous = jalali.withDay(1).addMonths(-1);
                            if (previous.monthLength != jalali.monthLength) {
                              if (jalali.day > previous.monthLength) {
                                jalali = jalali.copy(day: previous.monthLength);
                              }
                            }
                            if (jalali
                                    .addMonths(-1)
                                    .compareTo(Jalali.fromDateTime(now)) >=
                                0) {
                              jalali = jalali.addMonths(-1);
                            }

                            timeSink.add(jalali);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: ColorPalette.Yellow1,
                                  width: 1,
                                )),
                            child: Icon(
                              Icons.keyboard_arrow_left,
                              color: ColorPalette.Yellow1,
                              size: 24,
                            ),
                          ))
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Container(
                        height: 256,
                        child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: GridView.builder(
                              itemCount: jalali.monthLength +
                                  jalali
                                      .copy(
                                          year: jalali.year,
                                          month: jalali.month,
                                          day: 1)
                                      .weekDay -
                                  1,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 7),
                              itemBuilder: (BuildContext context, int index) {
                                var j = jalali
                                    .copy(
                                        year: jalali.year,
                                        month: jalali.month,
                                        day: 1)
                                    .weekDay;
                                return index + 1 < j
                                    ? Container()
                                    : GestureDetector(
                                        onTap: () {
                                          if (jalali
                                                  .withDay(index - j + 2)
                                                  .compareTo(
                                                      Jalali.fromDateTime(
                                                          now)) >=
                                              0) {
                                            jalali =
                                                jalali.withDay(index - j + 2);
                                            timeSink.add(jalali);
                                          }
                                        },
                                        child: new Container(
                                            width: 24,
                                            height: 16,
                                            child: MyText(
                                              text: (index - j + 2).toString(),
                                              textAlign: TextAlign.center,
                                              color: index - j + 2 == jalali.day
                                                  ? ColorPalette.Yellow1
                                                  : ColorPalette.Black1,
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                            )));
                              },
                            )))),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          //alignment: Alignment.centerRight,
                          widthFactor: 1,
                          child: MyButton(
                              text: Strings.BottomSheetWidget_DatePicker_cancel,
                              buttonFill: ButtonFillStyle.White,
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: FractionallySizedBox(
                          //alignment: Alignment.centerRight,
                          widthFactor: 1,
                          child: MyButton(
                              text: Strings.BottomSheetWidget_DatePicker_send,
                              buttonFill: ButtonFillStyle.Yellow,
                              onPressed: () {
                                String farsiDate = jalali.formatter.yyyy +
                                    '/' +
                                    jalali.formatter.mm +
                                    '/' +
                                    jalali.formatter.dd;
                                Navigator.of(context).pop({
                                  'date': this.jalali.toDateTime(),
                                  'farsi': farsiDate
                                });
                              }),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
