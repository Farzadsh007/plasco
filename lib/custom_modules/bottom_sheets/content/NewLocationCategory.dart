import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';
import 'package:plasco/models/location/location_category.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/views/location/NewLocationPageWidget.dart';

import '../../../color_palette.dart';
import '../../../locator.dart';
import '../../../strings.dart';
import '../../MyButton.dart';

class NewLocationCategoryWidget extends StatefulWidget {
  NewLocationCategoryWidget({Key key}) : super(key: key);

  @override
  _NewLocationCategoryWidgetState createState() =>
      _NewLocationCategoryWidgetState();
}

class _NewLocationCategoryWidgetState extends State<NewLocationCategoryWidget> {
  _NewLocationCategoryWidgetState();

  TextEditingController controller = TextEditingController();
  LocationCategory locationCategory = new LocationCategory();
  MyBloc httpBloc = MyBloc();
  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpBloc.stream.listen((event) {
      if (event != null) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NewLocationPageWidget(
                  locationCategory: locationCategory,
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
                  text: Strings
                      .BottomSheetWidget_NewLocationCategoryWidget_category_label,
                  color: ColorPalette.Black1,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                )),
            SizedBox(
              height: 24,
            ),
            MyTextFormField(
              controller: controller,
              text: Strings
                  .BottomSheetWidget_NewLocationCategoryWidget_category_name,
              hint: Strings
                  .BottomSheetWidget_NewLocationCategoryWidget_category_name,
              fontWeight: FontWeight.normal,
              fontSize: 12,
              counterFontSize: 10,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.text,
              maxLength: 35,validator:LocationCategoryNameValidator(5)
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
                          text: Strings
                              .BottomSheetWidget_NewLocationCategoryWidget_cancel,
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
                            text: Strings
                                .BottomSheetWidget_NewLocationCategoryWidget_send,
                            buttonFill: ButtonFillStyle.Yellow,
                            onPressed: () {
                              if( _formKey.currentState.validate()) {
                                locationCategory.title = controller.text;
                                locator<Web>().post(
                                    LocationCategoryAddEvent(
                                        httpBloc, this.locationCategory),
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
