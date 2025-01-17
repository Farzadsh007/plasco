import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';
import 'package:plasco/models/group/group_detail.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/views/group/EditGroupPageWidget.dart';

import '../../../color_palette.dart';
import '../../../locator.dart';
import '../../../strings.dart';
import '../../MyButton.dart';

class NewGroupWidget extends StatefulWidget {
  final MyBloc listHttpBloc;

  NewGroupWidget({Key key, this.listHttpBloc}) : super(key: key);

  @override
  _NewGroupWidgetState createState() => _NewGroupWidgetState(this.listHttpBloc);
}

class _NewGroupWidgetState extends State<NewGroupWidget> {
  _NewGroupWidgetState(this.listHttpBloc);

  TextEditingController controller = TextEditingController();
  GroupDetail groupDetail = new GroupDetail();
  MyBloc httpBloc = MyBloc();
  MyBloc listHttpBloc;
  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpBloc.stream.listen((event) {
      if (event == true) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditGroupPageWidget(
                  id: groupDetail.id,
                  listHttpBloc: listHttpBloc,
                )));
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
                  text: Strings.BottomSheetWidget_NewGroupWidget_group_label,
                  color: ColorPalette.Black1,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                )),
            SizedBox(
              height: 24,
            ),
            MyTextFormField(
              controller: controller,
              text: Strings.BottomSheetWidget_NewGroupWidget_group_name,
              hint: Strings.BottomSheetWidget_NewGroupWidget_group_name,
              fontWeight: FontWeight.normal,
              fontSize: 12,
              counterFontSize: 10,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.text,
              maxLength: 35,validator:GroupNameValidator(5)
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
                          text: Strings.BottomSheetWidget_NewGroupWidget_cancel,
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
                            text: Strings.BottomSheetWidget_NewGroupWidget_send,
                            buttonFill: ButtonFillStyle.Yellow,
                            onPressed: () {
    if( _formKey.currentState.validate()){
                                groupDetail.name = controller.text;
                                locator<Web>().post(
                                    GroupAddEvent(httpBloc, groupDetail),
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
