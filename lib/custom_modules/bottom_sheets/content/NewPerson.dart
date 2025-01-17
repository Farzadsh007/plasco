import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/SnackbarWidget.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/views/person/NewPersonPageWidget.dart';

import '../../../color_palette.dart';
import '../../../locator.dart';
import '../../../strings.dart';
import '../../MyButton.dart';

class NewPersonWidget extends StatefulWidget {

  NewPersonWidget({
    Key key,
  }) : super(key: key);

  @override
  _NewPersonWidgetState createState() => _NewPersonWidgetState( );
}

class _NewPersonWidgetState extends State<NewPersonWidget> {
  _NewPersonWidgetState( );

  TextEditingController controller = TextEditingController();

  MyBloc httpBloc = MyBloc();

  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpBloc.stream.listen((event) {

      Navigator.pop(context);
      if (event != null) {
        //exist
        User _user = event as User;
        if (_user.department == null || _user.department == -1) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NewPersonPageWidget(
                    user: _user,
                  )));
        } else {
          SnackBarWidget.buildErrorSnackBar(
              context, "کاربر قبلا عضو سایت شده است!");
        }
      } else {
        User _newUser=User();
        _newUser.national_code=controller.text ;
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => NewPersonPageWidget(user: _newUser,isFromAdd: true,)));
        /*
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            //enableDrag: false,//enable drag false only for map
            builder: (context) {
              return BottomSheetWidget(
                title: Strings.BottomSheetWidget_NewPersonOTP_title,
                content: NewPersonOTPWidget(
                  phone: controller.text,
                ),
              );
            });*/
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
    return Form(
        key: _formKey,child:Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                alignment: Alignment.centerRight,
                child: MyText(
                  text: Strings.BottomSheetWidget_NewPerson_label,
                  color: ColorPalette.Black1,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                )),
            SizedBox(
              height: 24,
            ),
            MyTextFormField(
              controller: controller,
              text: Strings.BottomSheetWidget_NewPerson_national_code_label,
              hint: Strings.national_national_NewPerson_national_code_hint,
              fontWeight: FontWeight.normal,
              fontSize: 12,
              counterFontSize: 10,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.number,
              maxLength: 10,validator:NationalCodeValidator(10)
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
                          text: Strings.BottomSheetWidget_NewPerson_cancel,
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
                            text: Strings.BottomSheetWidget_NewPerson_send,
                            buttonFill: ButtonFillStyle.Yellow,
                            onPressed: () {
                              if( _formKey.currentState.validate()) {
                                locator<Web>().post(
                                    PersonExistEvent(httpBloc, controller.text),
                                    context);
                              }
                            })),
                  )
                ],
              ),
            )
          ],
        )));
  }
}
