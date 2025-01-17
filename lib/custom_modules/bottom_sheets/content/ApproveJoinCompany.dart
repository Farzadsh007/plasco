import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/custom_modules/inputs/MyDropDownFormField.dart';
import 'package:plasco/models/DropDownItem.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/models/company/company.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';

import '../../../locator.dart';
import '../../../strings.dart';
import '../../LoadImage.dart';
import '../../inputs/MyText.dart';

class ApproveJoinCompanyWidget extends StatefulWidget {
  ApproveJoinCompanyWidget({
    Key key,
    @required this.user,
  }) : super(key: key);

  final User user;

  @override
  _ApproveJoinCompanyWidgetState createState() => _ApproveJoinCompanyWidgetState(
        this.user,
      );
}

class _ApproveJoinCompanyWidgetState extends State<ApproveJoinCompanyWidget> {
  _ApproveJoinCompanyWidgetState(this.user);

  User user;

  MyBloc sendRequestHttpBloc = MyBloc();
  Company company = new Company();
  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  void initState() {
    super.initState();


    company.department = user.department;
    company.job_title = user.job_title;
    company.user_role =user.user_role;
    sendRequestHttpBloc.stream.listen((event) async{
      if (event == true) {
        await locator<Web>().post(
            PersonGetListEvent(locator<Constants>().personListHttpBloc, ''),
            context);
        Navigator.of(context).pop();

      }
    });
  }

  @override
  void dispose() {

    sendRequestHttpBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,child:Column(
      mainAxisSize: MainAxisSize.min,
      children: [
      /*  Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerRight,
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: item.site_logo != ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: LoadImage.load(
                                  url: item.site_logo,
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
                                      text: item.organization_name,
                                      textAlign: TextAlign.right,
                                      color: ColorPalette.Black1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    SizedBox(height: 4),
                                    MyText(
                                      text: item.project_name,
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
                ),*/
        SizedBox(
          height: 24,
        ),
        MyDropDownFormField(selected: DropDownItem(user.department, user.department_title, null),
          httpEvent: DropDownGetUnitEvent(),
          bottomSheetTitle: Strings.CompanyPageWidget_unit,
          text: Strings.BottomSheetWidget_JoinCompany_unit,
          hint: Strings.BottomSheetWidget_choose,
          fontWeight: FontWeight.normal,
          fontSize: 12,
          onChange: (newValue) {
            company.department = newValue.id;
          },
        ),
        SizedBox(
          height: 24,
        ),
        MyDropDownFormField(selected: DropDownItem(user.job_title, user.job_title_name, null),
          httpEvent: DropDownGetJobTitleEvent(),
          bottomSheetTitle: Strings.CompanyPageWidget_job_title,
          text: Strings.BottomSheetWidget_JoinCompany_job_title,
          hint: Strings.BottomSheetWidget_choose,
          fontWeight: FontWeight.normal,
          fontSize: 12,
          onChange: (newValue) {
            company.job_title = newValue.id;
          },
        ),
        SizedBox(
          height: 24,
        ),
        MyDropDownFormField(selected: DropDownItem(user.user_role.index, user.getRole(), null),
          httpEvent: DropDownGetPermissionEvent(),
          bottomSheetTitle: Strings.CompanyPageWidget_permission,
          text: Strings.BottomSheetWidget_JoinCompany_permission,
          hint: Strings.BottomSheetWidget_choose,
          fontWeight: FontWeight.normal,
          fontSize: 12,
          onChange: (newValue) {
            company.user_role =
                role.values.firstWhere((i) => i.index == newValue.id);
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
                      text: Strings.BottomSheetWidget_JoinCompany_cancel,
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
                        text: Strings.BottomSheetWidget_ApproveJoinCompany_send,
                        buttonFill: ButtonFillStyle.Yellow,
                        onPressed: () {
                          if( _formKey.currentState.validate()){
                            locator<Web>().post(
                                PersonApproveRequestEvent(
                                    sendRequestHttpBloc, this.company,this.user),
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
