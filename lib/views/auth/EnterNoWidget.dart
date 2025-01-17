import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';
import 'VerifyNoWidget.dart';

class EnterNoWidget extends StatefulWidget {
  @override
  _EnterNoWidgetState createState() => _EnterNoWidgetState();
}

class _EnterNoWidgetState extends State<EnterNoWidget> {
  TextEditingController controller = TextEditingController();
  AuthEnterBloc httpBloc;
  final GlobalKey<FormState> _formKey = GlobalKey();
  Future<bool> _willPopCallback() async {
    bool ret = true;

    return ret;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpBloc = AuthEnterBloc();
    httpBloc.streamAuthEnterNo.listen((event) {
      if (event == true) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => VerifyNoWidget()));
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final enterNoWidgetPhone = MyTextFormField(
      controller: controller,
      text: Strings.EnterNoWidget_phone_label,
      hint: Strings.EnterNoWidget_phone_hint,
      fontWeight: FontWeight.normal,
      fontSize: 12,
      counterFontSize: 10,
      textAlign: TextAlign.left,
      keyboardType: TextInputType.phone,
      maxLength: 11,validator:MobileValidator(11)
    );
    final enterNoWidgetSendCode = MyButton(
        text: Strings.EnterNoWidget_send_code,
        buttonFill: ButtonFillStyle.Yellow,
        onPressed: () {
          if( _formKey.currentState.validate()) {
            locator<Web>()
                .post(AuthEnterNoEvent(httpBloc, controller.text), context);
          }
        });
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
            backgroundColor: ColorPalette.White2,
            body: Form(
        key: _formKey,child:SingleChildScrollView(
                child: Container(
                    width: width,
                    height: height,
                    child: Stack(
                        alignment: Alignment.topRight,
                        fit: StackFit.expand,
                        children: <Widget>[
                          Positioned(
                              top: 0.0,
                              left: 0.0,
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
                              top: 64.0,
                              right: 16.0,
                              child: Container(
                                  //  width: width / 2.5,
                                  child: MyText(
                                text: Strings.EnterNoWidget_header,
                                color: ColorPalette.White1,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                maxLines: 2,
                              ))),
                          Positioned(
                            top: 2.8 * height / 10,
                            left: 0.0,
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
                                                  .EnterNoWidget_phone_title,
                                              color: ColorPalette.Black1,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            )),

                                        SizedBox(height: 32),

                                        //  SizedBox(height : 16),

                                        enterNoWidgetPhone,
                                      ],
                                    ),
                                    Expanded(
                                        child: Container(
                                            alignment: Alignment.bottomCenter,
                                            child: FractionallySizedBox(
                                                //alignment: Alignment.centerRight,
                                                widthFactor: 1,
                                                child: enterNoWidgetSendCode)))
                                  ],
                                ),
                              ),
                            ),
                          )
                        ]))))));
  }
}
