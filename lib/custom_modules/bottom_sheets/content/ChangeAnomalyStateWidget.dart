import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/services/web.dart';

import '../../../locator.dart';
import '../../../strings.dart';
import '../../inputs/MyText.dart';

class ChangeAnomalyStateWidget extends StatefulWidget {
  ChangeAnomalyStateWidget(
      {Key key, @required this.changeAnomalyStateEnum, this.anomalyId})
      : super(key: key);

  final ChangeAnomalyStateEnum changeAnomalyStateEnum;
  final int anomalyId;

  @override
  _ChangeAnomalyStateWidgetState createState() =>
      _ChangeAnomalyStateWidgetState(
          this.changeAnomalyStateEnum, this.anomalyId);
}

class _ChangeAnomalyStateWidgetState extends State<ChangeAnomalyStateWidget> {
  _ChangeAnomalyStateWidgetState(this.changeAnomalyStateEnum, this.anomalyId);

  ChangeAnomalyStateEnum changeAnomalyStateEnum;
  int anomalyId;
  MyBloc httpBloc = MyBloc();

  @override
  void initState() {
    super.initState();
    httpBloc.stream.listen((event) {
      if (event == true) {
        Navigator.of(context).pop(true);

      }
    });
  }

  @override
  void dispose() {
    httpBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: MyText(
            text: changeAnomalyStateEnum == ChangeAnomalyStateEnum.Delete
                ? Strings.ChangeAnomalyState_prefix +
                    anomalyId.toString() +
                    Strings.ChangeAnomalyState_remove_suffix
                : Strings.ChangeAnomalyState_prefix +
                    anomalyId.toString() +
                    Strings.ChangeAnomalyState_edit_suffix,
            textAlign: TextAlign.right,
            color: ColorPalette.Black2,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(height: 24),
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
                      text: Strings.ChangeAnomalyState_cancel,
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
                        text: changeAnomalyStateEnum ==
                                ChangeAnomalyStateEnum.Delete
                            ? Strings.ChangeAnomalyState_remove
                            : Strings.ChangeAnomalyState_send,
                        buttonFill: ButtonFillStyle.Yellow,
                        onPressed: () {
                          switch (this.changeAnomalyStateEnum) {
                            case ChangeAnomalyStateEnum.Close:
                              locator<Web>().post(
                                  AnomalyCloseEvent(httpBloc, this.anomalyId),
                                  context);
                              break;
                            case ChangeAnomalyStateEnum.Open:
                              break;
                            case ChangeAnomalyStateEnum.Delete:
                              locator<Web>().post(
                                  AnomalyRemoveEvent(httpBloc, this.anomalyId),
                                  context);
                              break;
                          }
                        })),
              )
            ],
          ),
        )
      ],
    );
  }
}

enum ChangeAnomalyStateEnum { Close, Open, Delete }
