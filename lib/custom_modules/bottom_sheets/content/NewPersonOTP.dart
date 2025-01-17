import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/views/person/NewPersonPageWidget.dart';

import '../../../color_palette.dart';
import '../../../locator.dart';
import '../../../strings.dart';
import '../../MyButton.dart';

class NewPersonOTPWidget extends StatefulWidget {
  NewPersonOTPWidget({Key key, this.phone}) : super(key: key);

  final String phone;

  @override
  _NewPersonOTPWidgetState createState() =>
      _NewPersonOTPWidgetState(this.phone);
}

class _NewPersonOTPWidgetState extends State<NewPersonOTPWidget> {
  _NewPersonOTPWidgetState(this.phone);

  String phone;
  Timer timer;
  int currentNumber;
  TextEditingController controller = TextEditingController();
  final _timerStreamController = StreamController<int>.broadcast();

  StreamSink<int> get timerSink => _timerStreamController.sink;

  Stream<int> get streamTimer => _timerStreamController.stream;
  MyBloc sendPhoneHttpBloc = MyBloc();
  MyBloc sendOTPHttpBloc = MyBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      if (this.phone != null && this.phone.length == 11) {
        locator<Web>()
            .post(AuthEnterNoEvent(sendPhoneHttpBloc, this.phone), context);
      }
    });

    sendOTPHttpBloc.stream.listen((event) {
      if (event == true) {
        if (event == false) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => NewPersonPageWidget()));
        }
      }
    });
    setTimer();
  }

  @override
  void dispose() {
    if (timer != null) timer.cancel();
    _timerStreamController.close();
    sendPhoneHttpBloc.dispose();
    sendOTPHttpBloc.dispose();
    super.dispose();
  }

  setTimer() {
    currentNumber = 120;
    timer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      if (currentNumber > 0) {
        currentNumber = currentNumber - 1;
        timerSink.add(currentNumber);
      } else {
        currentNumber = 0;

        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                alignment: Alignment.centerRight,
                child: MyText(
                  text: Strings.BottomSheetWidget_NewPersonOTP_title_previous +
                      '*******' +
                      this.phone.substring(0, 4) +
                      Strings.BottomSheetWidget_NewPersonOTP_title_after,
                  color: ColorPalette.Black1,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                )),
            SizedBox(
              height: 8,
            ),
            StreamBuilder(
                stream: streamTimer,
                builder: (context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasData) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: () {
                              if (currentNumber == 0) {
                                locator<Web>().post(
                                    AuthEnterNoEvent(null, this.phone),
                                    context);
                                setTimer();
                              }
                            },
                            child: MyText(
                              text: Strings
                                  .BottomSheetWidget_NewPersonOTP_resend_code,
                              color: currentNumber > 0
                                  ? ColorPalette.Gray2
                                  : ColorPalette.Yellow1,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: MyText(
                            text: new Duration(seconds: currentNumber)
                                .toString()
                                .substring(2, 7),
                            color: ColorPalette.Black1,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }),
            SizedBox(
              height: 32,
            ),
            MyTextFormField(
              controller: controller,
              text: Strings.BottomSheetWidget_NewPersonOTP_code_label,
              hint: '****',
              fontWeight: FontWeight.normal,
              fontSize: 12,
              counterFontSize: 10,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
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
                          text: Strings.BottomSheetWidget_NewPersonOTP_cancel,
                          buttonFill: ButtonFillStyle.White,
                          onPressed: () {
                            Navigator.pop(context);
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
                            text: Strings.BottomSheetWidget_NewPersonOTP_send,
                            buttonFill: ButtonFillStyle.Yellow,
                            onPressed: () {
                              locator<Web>().post(
                                  AuthVerifyNoEvent(sendOTPHttpBloc, this.phone,
                                      controller.text),
                                  context);
                            })),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
