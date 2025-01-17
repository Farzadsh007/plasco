import 'dart:async';

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
import 'package:plasco/views/main/MainPageWidget.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class AccountInfoWidget extends StatefulWidget {
  final String otp;

  AccountInfoWidget(this.otp);

  @override
  _AccountInfoWidgetState createState() => _AccountInfoWidgetState(this.otp);
}

class _AccountInfoWidgetState extends State<AccountInfoWidget> {
  String otp;

  _AccountInfoWidgetState(this.otp);

  TextEditingController nameController = TextEditingController();
  TextEditingController familyController = TextEditingController();
  TextEditingController nationalCodeController = TextEditingController();
  AuthEnterBloc httpBloc = AuthEnterBloc();
  final GlobalKey<FormState> _formKey = GlobalKey();
  Future<bool> _willPopCallback() async {
    bool ret = true;

    return ret;
  }

  @override
  void initState() {
    super.initState();
    httpBloc.streamAuthEnterNo.listen((event) {
      if (event == true) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainPageWidget()),
            (Route<dynamic> route) => false);
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

    final accountInfoWidgetName = MyTextFormField(
      controller: nameController,
      text: Strings.AccountInfoWidget_Name_label,
      hint: Strings.AccountInfoWidget_Name_label,
      fontWeight: FontWeight.normal,
      fontSize: 12,
      counterFontSize: 10,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.name,
      maxLength: 20,validator:NameValidator(5)
    );

    final accountInfoWidgetFamily = MyTextFormField(
      controller: familyController,
      text: Strings.AccountInfoWidget_Family_label,
      hint: Strings.AccountInfoWidget_Family_label,
      fontWeight: FontWeight.normal,
      fontSize: 12,
      counterFontSize: 10,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.name,
      maxLength: 35,validator:FamilyValidator(5)
    );

    final accountInfoWidgetNationalCode = MyTextFormField(
      controller: nationalCodeController,
      text: Strings.AccountInfoWidget_NationalCode_label,
      hint: Strings.AccountInfoWidget_NationalCode_label,
      fontWeight: FontWeight.normal,
      fontSize: 12,
      counterFontSize: 10,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      maxLength: 10,validator:NationalCodeValidator(10)
    );

    final accountInfoWidgetChangePhone = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
            onTap: () {},
            child: MyText(
              text: Strings.AccountInfoWidget_change_phone,
              color: ColorPalette.Yellow1,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
        Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: MyText(
              text: Strings.AccountInfoWidget_already_registered,
              color: ColorPalette.Black1,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
    final accountInfoWidgetApprove = MyButton(
        text: Strings.AccountInfoWidget_approve,
        buttonFill: ButtonFillStyle.Yellow,
        onPressed: () {
          if( _formKey.currentState.validate()){
            locator<Web>().post(
                AuthAccountInfoEvent(httpBloc, nameController.text,
                    familyController.text, this.otp, nationalCodeController.text),
                context);
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
                                text: Strings.AccountInfoWidget_header,
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
                                                  .AccountInfoWidget_title,
                                              color: ColorPalette.Black1,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            )),

                                        SizedBox(height: 32),

                                        //  SizedBox(height : 16),

                                        accountInfoWidgetName,
                                        accountInfoWidgetFamily,
                                        accountInfoWidgetNationalCode,
                                        SizedBox(height: 32),
                                        accountInfoWidgetChangePhone
                                      ],
                                    ),
                                    Expanded(
                                        child: Container(
                                            alignment: Alignment.bottomCenter,
                                            child: FractionallySizedBox(
                                                //alignment: Alignment.centerRight,
                                                widthFactor: 1,
                                                child:
                                                    accountInfoWidgetApprove)))
                                  ],
                                ),
                              ),
                            ),
                          )
                        ]))))));
  }
}
