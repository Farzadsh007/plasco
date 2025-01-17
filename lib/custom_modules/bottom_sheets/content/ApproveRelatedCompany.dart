import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/custom_modules/inputs/MyDropDownFormField.dart';
import 'package:plasco/models/DropDownItem.dart';
import 'package:plasco/models/company/company.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';

import '../../../locator.dart';
import '../../../strings.dart';
import '../../LoadImage.dart';
import '../../inputs/MyText.dart';

class ApproveRelatedCompanyWidget extends StatefulWidget {
  ApproveRelatedCompanyWidget({Key key, this.company }) : super(key: key);

  final Company company;

  @override
  _ApproveRelatedCompanyWidgetState createState() =>
      _ApproveRelatedCompanyWidgetState(this.company );
}

class _ApproveRelatedCompanyWidgetState extends State<ApproveRelatedCompanyWidget> {
  _ApproveRelatedCompanyWidgetState(this.company );

  MyBloc httpBloc = MyBloc();

  Company company;
  int connectionType;
  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpBloc.stream.listen((event) async{
      if (event as bool == true) {

        await locator<Web>().post(RelatedCompanyGetListEvent(locator<Constants>().relatedCompanyListHttpBloc,''), context);
        Navigator.of(context).pop();
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
        key: _formKey,child:Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          textDirection: TextDirection.rtl,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              alignment: Alignment.centerRight,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: company.site_logo != ''
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: LoadImage.load(
                          url: company.site_logo,
                          height: 24,
                          width: 24,
                          fit: BoxFit.fitHeight))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Center(
                          child: SvgPicture.asset(
                              'assets/vectors/Icons/image.svg',
                              width: 24,
                              height: 24))),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.rtl,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            MyText(
                              text: company.organization_name,
                              textAlign: TextAlign.right,
                              color: ColorPalette.Black1,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                            SizedBox(height: 4),
                            MyText(
                              text: company.project_name,
                              textAlign: TextAlign.right,
                              color: ColorPalette.Gray2,
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                            )
                          ],
                        ),
                      ])),
            ),
          ],
        ),
        SizedBox(
          height: 24,
        ),
        MyDropDownFormField(
          selected: DropDownItem(company.stake_holder_type_id,company.stake_holder_type,null),
          bottomSheetTitle: Strings.BottomSheetWidgetRelatedCompany_title,
          text: Strings.BottomSheetWidgetRelatedCompany_connection_type,
          hint: Strings.BottomSheetWidget_choose,
          fontWeight: FontWeight.normal,
          fontSize: 12,
          onChange: (newValue) {

          },
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
                      text: Strings.BottomSheetWidgetRelatedCompany_cancel,
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
                        text: Strings.BottomSheetWidgetApproveRelatedCompany_send,
                        buttonFill: ButtonFillStyle.Yellow,
                        onPressed: () {
                          if( _formKey.currentState.validate()){
                            locator<Web>().post(
                                RelatedCompanyApproveRequestEvent(
                                    httpBloc, this.company),
                                context);
                          }

                        })),
              )
            ],
          ),
        )
      ],
    ));
  }
}
