import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/models/action/action.dart';
import 'package:plasco/services/web.dart';

import '../../../locator.dart';
import '../../../strings.dart';
import '../../inputs/MyText.dart';

class ApproveActionWidget extends StatefulWidget {
  ApproveActionWidget({Key key, this.action}) : super(key: key);

  final ActionItem action;

  @override
  _ApproveActionWidgetState createState() =>
      _ApproveActionWidgetState(this.action);
}

class _ApproveActionWidgetState extends State<ApproveActionWidget> {
  _ApproveActionWidgetState(this.action);

  ActionItem action;
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
            text: Strings.ApproveActionWidget_prefix +
                '[' +
                action.id.toString() +
                ']' +
                Strings.ApproveActionWidget_suffix,
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
                      text: Strings.ApproveActionWidget_cancel,
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
                        text: Strings.ApproveActionWidget_send,
                        buttonFill: ButtonFillStyle.Yellow,
                        onPressed: () {
                          locator<Web>().post(
                              ActionApproveEvent(httpBloc, this.action),
                              context);
                        })),
              )
            ],
          ),
        )
      ],
    );
  }
}
