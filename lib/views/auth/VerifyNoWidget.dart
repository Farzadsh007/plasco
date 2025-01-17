import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';
import 'package:plasco/views/auth/AccountInfoWidget.dart';
import 'package:plasco/views/main/MainPageWidget.dart';

import '../../locator.dart';

class VerifyNoWidget extends StatefulWidget {
  @override
  _VerifyNoWidgetState createState() => _VerifyNoWidgetState();
}

class _VerifyNoWidgetState extends State<VerifyNoWidget> {
  Timer timer;
  int currentNumber;
  TextEditingController controller = TextEditingController();
  AuthEnterBloc httpBloc = AuthEnterBloc();
  final GlobalKey<FormState> _formKey = GlobalKey();
  Future<bool> _willPopCallback() async {
    bool ret = true;

    return ret;
  }

  final _timerStreamController = StreamController<int>.broadcast();

  StreamSink<int> get timerSink => _timerStreamController.sink;

  Stream<int> get streamTimer => _timerStreamController.stream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setTimer();
    httpBloc.streamAuthEnterNo.listen((event) {
      if (event == false) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => AccountInfoWidget(controller.text)),
            (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainPageWidget()),
            (Route<dynamic> route) => false);
      }
    });
  }

  @override
  void dispose() {
    if (timer != null) timer.cancel();
    _timerStreamController.close();
    httpBloc.dispose();
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final verifyNoWidgetPhone = MyTextFormField(
      controller: controller,
      text: Strings.VerifyNoWidget_label,
      hint: '****',
      fontWeight: FontWeight.normal,
      fontSize: 12,
      counterFontSize: 10,
      textAlign: TextAlign.left,
      keyboardType: TextInputType.number,
      maxLength: 4,validator:OTPValidator(4)
    );

    final verifyNoWidgetResendCode = StreamBuilder(
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
                            AuthEnterNoEvent(
                                null, locator<Constants>().MyPhone),
                            context);
                        setTimer();
                      }
                    },
                    child: MyText(
                      text: Strings.VerifyNoWidget_resend_code,
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
        });

    final verifyNoWidgetChangePhone = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: MyText(
              text: Strings.VerifyNoWidget_change_phone,
              color: ColorPalette.Yellow1,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: MyText(
            text: Strings.VerifyNoWidget_phone_replace,
            color: ColorPalette.Black1,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
    final verifyNoWidgetSendCode = MyButton(
        text: Strings.VerifyNoWidget_verify,
        buttonFill: ButtonFillStyle.Yellow,
        onPressed: () {

          if( _formKey.currentState.validate()){
            locator<Web>().post(
                AuthVerifyNoEvent(
                    httpBloc, locator<Constants>().MyPhone, controller.text),
                context);
          }

        });
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
            backgroundColor: ColorPalette.White2,
            body:Form(
        key: _formKey,child: SingleChildScrollView(
                child: Container(
                    width: width,
                    height: height,
                    child: Stack(
                        alignment: Alignment.topRight,
                        fit: StackFit.expand,
                        children: <Widget>[
                          Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                  width: width,
                                  height: height / 2.6,
                                  alignment: Alignment.topCenter,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/Twocolleaguesfactory.jpg'),
                                        fit: BoxFit.fitWidth),
                                  ))),
                          Positioned(
                              top: 64,
                              right: 16,
                              child: Container(
                                  // width: width / 2.5,
                                  child: MyText(
                                text: Strings.VerifyNoWidget_header,
                                color: ColorPalette.White1,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                maxLines: 2,
                              ))),
                          Positioned(
                            top: 2.8 * height / 10,
                            left: 0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                width: width - 16,
                                height: 7 * height / 10,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: ColorPalette.Gray1.withOpacity(
                                            0.25),
                                        offset: Offset(0, 0),
                                        blurRadius: 4)
                                  ],
                                  color: ColorPalette.White1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(height: 32),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Container(
                                            alignment: Alignment.centerRight,
                                            child: MyText(
                                              text: Strings
                                                      .VerifyNoWidget_title_previous +
                                                  locator<Constants>()
                                                      .MyPhone
                                                      .substring(9) +
                                                  '***' +
                                                  locator<Constants>()
                                                      .MyPhone
                                                      .substring(0, 4) +
                                                  Strings
                                                      .VerifyNoWidget_title_after,
                                              color: ColorPalette.Black1,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            )),

                                        SizedBox(height: 32),

                                        //  SizedBox(height : 16),

                                        verifyNoWidgetPhone,
                                        verifyNoWidgetResendCode,
                                        SizedBox(height: 32),
                                        verifyNoWidgetChangePhone
                                      ],
                                    ),
                                    Expanded(
                                        child: Container(
                                            alignment: Alignment.bottomCenter,
                                            child: FractionallySizedBox(
                                                //alignment: Alignment.centerRight,
                                                widthFactor: 1,
                                                child: verifyNoWidgetSendCode)))
                                  ],
                                ),
                              ),
                            ),
                          )
                        ]))))));
  }
}
