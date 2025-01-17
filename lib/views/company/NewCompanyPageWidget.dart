import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plasco/blocs/ChooseFileBloc.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ChooseFile.dart';
import 'package:plasco/custom_modules/inputs/MyDropDownFormField.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';
import 'package:plasco/models/DropDownItem.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/models/company/company.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class NewCompanyPageWidget extends StatefulWidget {
  final bool isForEdit;

  const NewCompanyPageWidget({Key key, @required this.isForEdit })
      : super(key: key);

  @override
  _NewCompanyPageWidgetState createState() =>
      _NewCompanyPageWidgetState(this.isForEdit );
}

class _NewCompanyPageWidgetState extends State<NewCompanyPageWidget> {
  bool isForEdit;

  MyBloc httpBloc = MyBloc();
  MyBloc companyDetailsHttpBloc = MyBloc();
  Company company = new Company();

  _NewCompanyPageWidgetState(this.isForEdit );



  TextEditingController companyPageWidgetNameController =
  TextEditingController();
  TextEditingController companyPageWidgetProjectNameController =
  TextEditingController();
  TextEditingController companyPageWidgetPhoneController =
  TextEditingController();

  Uint8List image;

  final ChooseFileBloc chooseFileBloc = ChooseFileBloc();
  final GlobalKey<FormState> _formKey = GlobalKey();
  Future<bool> _willPopCallback() async {
    bool ret = true;
    await locator<Web>().post(CompanyGetListEvent(locator<Constants>().companyListHttpBloc, ''), context);

    return ret;
  }

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    String mySiteId = locator<Constants>().getSite_id();


    Future.delayed(Duration.zero, () {
      if (isForEdit && mySiteId != '') {
        locator<Web>().post(
            CompanyGetDetailsEvent(companyDetailsHttpBloc, int.parse(mySiteId)),
            context);
      } else {
        companyDetailsHttpBloc.add(this.company);
      }
    });


    httpBloc.stream.listen((event) async{
      if (event as bool == true) {
      await locator<Web>().post(
            AuthGetMemberShipEvent(locator<Constants>().memberShipHttpBloc),
            context);
        Navigator.of(context).pop(true);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    httpBloc.dispose();
    companyDetailsHttpBloc.dispose();
    chooseFileBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
/*    DropDownCityGetContentEvent cityGetContentEvent=DropDownCityGetContentEvent();
    final companyPageWidgetProvence = MyDropDownFormField(httpEvent: DropDownProvinceGetContentEvent(),
      text: Strings.CompanyPageWidget_Province,
      hint: Strings.CompanyPageWidget_choose,
      fontWeight: FontWeight.normal,
      fontSize: 12,onChange: (newValue ){
        cityGetContentEvent.province=newValue.id;
        sinkProvinceChanged.add(newValue.id);
    },
    );

    final companyPageWidgetCity =StreamBuilder(
        stream: streamProvinceChanged,
        builder: (context,
        AsyncSnapshot<int> snapshot) {
          return MyDropDownFormField(httpEvent: cityGetContentEvent,
            text: Strings.CompanyPageWidget_city,
            hint: Strings.CompanyPageWidget_choose,
            fontWeight: FontWeight.normal,
            fontSize: 12,
            onChange: (newValue) {
              var ff = '';
            },
          );
        });*/

    final companyPageWidgetCancel = MyButton(
        text: Strings.CompanyPageWidget_cancel,
        buttonFill: ButtonFillStyle.White,
        onPressed: () {
          Navigator.pop(context, true);
        });
    final companyPageWidgetApprove = MyButton(
        text: Strings.CompanyPageWidget_send,
        buttonFill: ButtonFillStyle.Yellow,
        onPressed: ()
    {
      if( _formKey.currentState.validate()){
      this.company.organization_name = companyPageWidgetNameController.text;
      this.company.project_name =
          companyPageWidgetProjectNameController.text;
      this.company.phone = companyPageWidgetPhoneController.text;
      this.company.image = this.image;
      if (isForEdit) {
        locator<Web>()
            .post(CompanyUpdateEvent(httpBloc, this.company), context);
      } else {
        locator<Web>()
            .post(CompanyAddNewEvent(httpBloc, this.company), context);
      }
    }
        });
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
          backgroundColor: ColorPalette.Background,
          body:Form(
        key: _formKey,child: SafeArea(
              child: Container(
                  color: Colors.transparent,

                  // height: height /2,
                  child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalette.White1,
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: <
                          Widget>[
                        Container(
                            decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: ColorPalette.Black3),
                                )),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child:
                            // SizedBox(width : 268),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                    child: MyText(
                                      text: isForEdit
                                          ? Strings.CompanyPageWidget_edit
                                          : Strings.CompanyPageWidget_new,
                                      textAlign: TextAlign.center,
                                      color: ColorPalette.Gray1,
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                    )),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.close,
                                      color: ColorPalette.Gray2,
                                    ),
                                    onTap: () async{
                                      await locator<Web>().post(
                                          CompanyGetListEvent(locator<Constants>().companyListHttpBloc, ''),
                                      context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            )),
                        StreamBuilder(
                            stream: companyDetailsHttpBloc.stream,
                            builder: (context,
                                AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.hasData) {
                                Company company = snapshot.data as Company;
                                this.company = company;
                                User _userForRole = User();
                                _userForRole.user_role = company.user_role;
                                companyPageWidgetNameController.text =
                                    company.organization_name;

                                companyPageWidgetProjectNameController.text =
                                    company.project_name;
                                companyPageWidgetPhoneController.text =
                                    company.phone;
                                return Expanded(
                                  child: SingleChildScrollView(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: ColorPalette.White1,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 16),
                                      child: Column(children: [
                                        Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    //enableDrag: false,//enable drag false only for map
                                                    builder: (context) {
                                                      return BottomSheetWidget(
                                                        title: Strings
                                                            .BottomSheetWidget_ChooseFile_title,
                                                        content: ChooseFileWidget(
                                                          chooseFileBloc:
                                                          chooseFileBloc,
                                                          enableEdit: false,),
                                                      );
                                                    });
                                              },
                                              child: StreamBuilder(
                                                  stream:
                                                  chooseFileBloc
                                                      .streamChooseFile,
                                                  builder: (context,
                                                      AsyncSnapshot<Uint8List>
                                                      snapshot) {
                                                    if (snapshot.hasData) {
                                                      this.image =
                                                          snapshot.data;
                                                      return Container(
                                                          alignment: Alignment
                                                              .center,
                                                          width: 56,
                                                          height: 56,
                                                          decoration: BoxDecoration(
                                                              color: ColorPalette
                                                                  .Black2
                                                                  .withOpacity(
                                                                  0.5),
                                                              borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                      8)),
                                                              image: DecorationImage(
                                                                  image: MemoryImage(
                                                                    snapshot
                                                                        .data,
                                                                  ))));
                                                    } else {
                                                      return company
                                                          .site_logo != ''
                                                          ? Container(
                                                          alignment: Alignment
                                                              .center,
                                                          width: 56,
                                                          height: 56,
                                                          decoration: BoxDecoration(
                                                              color: ColorPalette
                                                                  .Black2
                                                                  .withOpacity(
                                                                  0.5),
                                                              borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                      8))),
                                                          child: LoadImage.load(
                                                              url: company
                                                                  .site_logo,

                                                              fit: BoxFit
                                                                  .fitHeight))
                                                          : Container(
                                                          alignment: Alignment
                                                              .center,
                                                          width: 56,
                                                          height: 56,
                                                          decoration: BoxDecoration(
                                                              color: ColorPalette
                                                                  .Black2
                                                                  .withOpacity(
                                                                  0.5),
                                                              borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                      8))),
                                                          child: Icon(
                                                            Icons
                                                                .camera_alt_outlined,
                                                            size: 24,
                                                            color: ColorPalette
                                                                .White1,
                                                          ));
                                                    }
                                                  }),
                                            )),
                                        SizedBox(height: 32),
                                        MyTextFormField(
                                          controller: companyPageWidgetNameController,
                                          text: Strings.CompanyPageWidget_Name,
                                          hint: Strings.CompanyPageWidget_Name,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          counterFontSize: 10,
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.name,
                                          maxLength: 35,validator:CompanyNameValidator(5)
                                        ),
                                        SizedBox(height: 24),
                                        Row(
                                          textDirection: TextDirection.rtl,
                                          mainAxisAlignment: MainAxisAlignment
                                              .start,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Switch(
                                              value: this.company
                                                  .is_central_office,
                                              onChanged: (value) {
                                                this.company.is_central_office =
                                                    value;
                                                if (value == true) {
                                                  this.company.project_name =
                                                  'دفتر مرکزی';
                                                } else {
                                                  this.company.project_name =
                                                  '';
                                                }
                                                companyDetailsHttpBloc.add(
                                                    this.company);
                                              },
                                              activeTrackColor: ColorPalette
                                                  .Green1,
                                              activeColor: ColorPalette.White1,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            MyText(
                                              text: Strings
                                                  .CompanyPageWidget_ThisIsCentral,
                                              textAlign: TextAlign.right,
                                              color: ColorPalette.Black1,
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 24),
                                        if (!company
                                            .is_central_office) MyTextFormField(
                                          controller:
                                          companyPageWidgetProjectNameController,
                                          text: Strings
                                              .CompanyPageWidget_ProjectName,
                                          hint: Strings
                                              .CompanyPageWidget_ProjectName,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          counterFontSize: 10,
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.name,
                                          maxLength: 35,validator:CompanyProjectNameValidator(5)
                                        ),
                                        SizedBox(height: 24),
                                        MyDropDownFormField(
                                          selected: !isForEdit
                                              ? null
                                              : DropDownItem(
                                              -1, 'انتخاب شد!', null),
                                          httpEvent: DropDownCityMapEvent(),
                                          bottomSheetTitle:
                                          Strings
                                              .BottomSheetWidget_Location_title,
                                          text: Strings
                                              .CompanyPageWidget_location,
                                          hint: Strings
                                              .CompanyPageWidget_choose,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          onChange: (newValue) {
                                            LatLng value = newValue
                                                .data as LatLng;
                                            this.company.lat =
                                                value.latitude.toString();
                                            this.company.lng =
                                                value.longitude.toString();
                                          },
                                        ),
                                        /*  companyPageWidgetProvence,
                                SizedBox(height: 24),
                                companyPageWidgetCity,*/

                                        SizedBox(height: 24),
                                        MyTextFormField(
                                          controller: companyPageWidgetPhoneController,
                                          text: Strings.CompanyPageWidget_phone,
                                          hint: Strings.CompanyPageWidget_phone,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          counterFontSize: 10,
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 11,validator:PhoneValidator(4)
                                        ),
                                        /*  SizedBox(height: 24),
                                MyDropDownFormField(selected:!isForEdit?null: DropDownItem(company.site_type,company.site_type_title,null),
                                  httpEvent: DropDownGetCompanyTypeEvent(),
                                  bottomSheetTitle:
                                      Strings.CompanyPageWidget_companyType,
                                  text: Strings.CompanyPageWidget_companyType,
                                  hint: Strings.CompanyPageWidget_choose,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  onChange: (newValue) {
                                    this.company.site_type = newValue.id;
                                  },
                                ),*/
                                        SizedBox(height: 24),
                                        MyDropDownFormField(
                                          selected: !isForEdit
                                              ? null
                                              : DropDownItem(company.site_scope,
                                              company.site_scope_title, null),
                                          httpEvent: DropDownGetWorkingFieldEvent(),
                                          bottomSheetTitle: Strings
                                              .CompanyPageWidget_WorkingField_title,
                                          text: Strings
                                              .CompanyPageWidget_WorkingField_title,
                                          hint: Strings
                                              .CompanyPageWidget_choose,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          onChange: (newValue) {
                                            this.company.site_scope =
                                                newValue.id;
                                          },
                                        ),
                                        SizedBox(height: 24),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: MyText(
                                            text: Strings
                                                .CompanyPageWidget_edit_your_factory_data,
                                            textAlign: TextAlign.right,
                                            color: ColorPalette.Black1,
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        SizedBox(height: 24),
                                        MyDropDownFormField(
                                          selected: !isForEdit
                                              ? null
                                              : DropDownItem(company.department,
                                              company.department_title, null),
                                          httpEvent: DropDownGetUnitEvent(),
                                          bottomSheetTitle:
                                          Strings.CompanyPageWidget_unit,
                                          text: Strings.CompanyPageWidget_unit,
                                          hint: Strings
                                              .CompanyPageWidget_choose,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          onChange: (newValue) {
                                            this.company.department =
                                                newValue.id;
                                          },
                                        ),
                                        SizedBox(height: 24),
                                        MyDropDownFormField(
                                          selected: !isForEdit
                                              ? null
                                              : DropDownItem(company.job_title,
                                              company.job_title_name, null),
                                          httpEvent: DropDownGetJobTitleEvent(),
                                          bottomSheetTitle:
                                          Strings.CompanyPageWidget_job_title,
                                          text: Strings
                                              .CompanyPageWidget_job_title,
                                          hint: Strings
                                              .CompanyPageWidget_choose,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          onChange: (newValue) {
                                            this.company.job_title =
                                                newValue.id;
                                          },
                                        ),
                                        SizedBox(height: 24),
                                        MyDropDownFormField(
                                          selected: !isForEdit
                                              ? null
                                              : DropDownItem(
                                              company.user_role.index,
                                              _userForRole.getRole(), null),
                                          httpEvent: DropDownGetPermissionEvent(),
                                          bottomSheetTitle:
                                          Strings.CompanyPageWidget_permission,
                                          text: Strings
                                              .CompanyPageWidget_permission,
                                          hint: Strings
                                              .CompanyPageWidget_choose,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          onChange: (newValue) {
                                            this.company.user_role = role.values
                                                .firstWhere(
                                                    (i) =>
                                                i.index == newValue.id);
                                          },
                                        ),
                                        SizedBox(height: 24),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 24.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            textDirection: TextDirection.rtl,
                                            children: [
                                              Expanded(
                                                child: FractionallySizedBox(
                                                  //alignment: Alignment.centerRight,
                                                  widthFactor: 1,
                                                  child: companyPageWidgetCancel,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 8.0,
                                              ),
                                              Expanded(
                                                child: FractionallySizedBox(
                                                  //alignment: Alignment.centerRight,
                                                    widthFactor: 1,
                                                    child: companyPageWidgetApprove),
                                              )
                                            ],
                                          ),
                                        )
                                      ]),
                                    ),
                                  ),
                                );
                              }
                              else {
                                return Expanded(child: Center(
                                  child: CircularProgressIndicator(),));
                              }
                            })
                      ])

                  ))))),
    );
  }
}
