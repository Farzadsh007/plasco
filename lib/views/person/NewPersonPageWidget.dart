import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plasco/blocs/ChooseFileBloc.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/CrossPlatformSvg.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ChooseFile.dart';
import 'package:plasco/custom_modules/inputs/MyDropDownFormField.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';
import 'package:plasco/models/DropDownItem.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';
import 'package:plasco/models/auth/enums.dart';
import '../../color_palette.dart';
import '../../locator.dart';

class NewPersonPageWidget extends StatefulWidget {
  final User user;

  final bool isFromAdd;
  const NewPersonPageWidget({Key key, this.user, this.isFromAdd}) : super(key: key);

  @override
  _NewPersonPageWidgetState createState() =>
      _NewPersonPageWidgetState(this.user, this.isFromAdd);
}

class _NewPersonPageWidgetState extends State<NewPersonPageWidget> {
  _NewPersonPageWidgetState(this.user ,this.isFromAdd);

  User user;
  MyBloc httpBloc = MyBloc();
  MyBloc sendHttpBloc = MyBloc();

  Uint8List image;
  bool isFromAdd;
  final ChooseFileBloc chooseFileBloc = ChooseFileBloc();
  TextEditingController personPageWidgetNameController =
      TextEditingController();
  TextEditingController personPageWidgetFamilyController =
      TextEditingController();
  TextEditingController personPageWidgetPhoneController =
      TextEditingController();
  TextEditingController personPageWidgetNationalCodeController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  Future<bool> _willPopCallback() async {
    bool ret = true;
    await locator<Web>().post(PersonGetListEvent(locator<Constants>().personListHttpBloc, ''), context);

    return ret;
  }

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();

    httpBloc.stream.listen((event) {
      User user = event as User;

      if (user != null && user.id!=null) {
        // this.user=user;
        personPageWidgetNameController.text = user.first_name;

        personPageWidgetFamilyController.text = user.last_name;

        personPageWidgetPhoneController.text = user.mobile_number;

        personPageWidgetNationalCodeController.text = user.national_code;
      }
      if (user != null &&  user.id==null && isFromAdd==true) {


        personPageWidgetNationalCodeController.text = user.national_code;
      }

    });
    if (user != null && user.id!=null) {


      Future.delayed(Duration.zero, () {
        locator<Web>().post(AuthGetProfileEvent(httpBloc, user), context);
      });
    } else {
      Future.delayed(Duration.zero, () {
        httpBloc.add(user);
      });

    }


    sendHttpBloc.stream.listen((event) async {
      if (event as bool == true) {
        await locator<Web>().post(PersonGetListEvent(locator<Constants>().personListHttpBloc,''), context);

        if (user != null &&
            user.id != null &&
            user.id == locator<Constants>().UserID){

          await locator<Web>().post(AuthGetMemberShipEvent(locator<Constants>().memberShipHttpBloc), context);
          locator<Constants>().profileHttpBloc.sink.add(this.user);
          Navigator.of(context).pop();
        }

      }
    });
  }

  @override
  void dispose() {
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    httpBloc.dispose();
    sendHttpBloc.dispose();
    chooseFileBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personPageWidgetUnit = MyDropDownFormField(
      selected: (user == null || user.id == null)
          ? null
          : DropDownItem(user.department, user.department_title, null),
      httpEvent: DropDownGetUnitEvent(),
      bottomSheetTitle: Strings.BottomSheetWidget_JoinCompany_unit,
      text: Strings.PersonPageWidget_unit,
      hint: Strings.PersonPageWidget_choose,
      fontWeight: FontWeight.normal,
      fontSize: 12,
      onChange: (newValue) {
        this.user.department = newValue.id;
      },
    );
    final personPageWidgetJobTitle = MyDropDownFormField(
      selected: (user == null || user.id == null)
          ? null
          : DropDownItem(user.job_title, user.job_title_name, null),
      httpEvent: DropDownGetJobTitleEvent(),
      bottomSheetTitle: Strings.BottomSheetWidget_JoinCompany_job_title,
      text: Strings.PersonPageWidget_job_title,
      hint: Strings.PersonPageWidget_choose,
      fontWeight: FontWeight.normal,
      fontSize: 12,
      onChange: (newValue) {
        this.user.job_title = newValue.id;
      },
    );

    final personPageWidgetCancel = MyButton(
        text: Strings.PersonPageWidget_cancel,
        buttonFill: ButtonFillStyle.White,
        onPressed: () {
          Navigator.of(context).pop();
        });
    final personPageWidgetApprove = MyButton(
        text: Strings.PersonPageWidget_send,
        buttonFill: ButtonFillStyle.Yellow,
        onPressed: () {


         if( _formKey.currentState.validate()) {
           this.user.first_name = personPageWidgetNameController.text;
           this.user.last_name = personPageWidgetFamilyController.text;
           this.user.mobile_number =
               personPageWidgetPhoneController.text;
           this.user.national_code =
               personPageWidgetNationalCodeController.text;
           this.user.image = this.image;

           if (isFromAdd) {
             locator<Web>().post(
                 AuthCreateUpdateProfileShipEvent(sendHttpBloc, this.user),
                 context);
           } else {
             locator<Web>().post(
                 AuthUpdateProfileShipEvent(sendHttpBloc, this.user), context);
           }
         }
         /* if (this.user != null && this.user.id!=null) {
            //update
            this.user.first_name = personPageWidgetNameController.text;
            this.user.last_name = personPageWidgetFamilyController.text;
            this.user.national_code =
                personPageWidgetNationalCodeController.text;
            this.user.image = this.image;
            if (userNotInMemberShip) {
              locator<Web>().post(
                  PersonAddNewMembershipEvent(sendHttpBloc, this.user),
                  context);
            } else {
              locator<Web>().post(
                  AuthUpdateProfileShipEvent(sendHttpBloc, this.user), context);
            }
          } else {
            locator<Web>()
                .post(PersonAddNewEvent(sendHttpBloc, this.user), context);
          }*/
        });
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          backgroundColor: ColorPalette.Background,
          body:  Form(
        key: _formKey,child:SafeArea(
              child: Container(
                  color: Colors.transparent,

                  // height: height /2,
                  child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalette.White1,
                      ),
                      child:Column(mainAxisSize: MainAxisSize.min, children: <
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
                                  text:
                                      this.user == null || this.user.id == null
                                          ? Strings.PersonPageWidget_new
                                          : Strings.PersonPageWidget_edit,
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
                                      await locator<Web>().post(PersonGetListEvent(locator<Constants>().personListHttpBloc, ''), context);
                                      Navigator.pop(context, true);
                                    },
                                  ),
                                ),
                              ],
                            )),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorPalette.White1,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Column(children: [
                                StreamBuilder(
                                    stream: httpBloc.stream,
                                    builder: (context,
                                        AsyncSnapshot<dynamic> snapshot) {
                                      if (snapshot.hasData) {
                                        User user = snapshot.data as User;
                                        return Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              onTap: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    //enableDrag: false,//enable drag false only for map
                                                    builder: (context) {
                                                      return BottomSheetWidget(
                                                        title: Strings
                                                            .BottomSheetWidget_ChooseFile_title,
                                                        content:
                                                            ChooseFileWidget(
                                                          chooseFileBloc:
                                                              chooseFileBloc,
                                                          enableEdit: false,
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: StreamBuilder(
                                                  stream: chooseFileBloc
                                                      .streamChooseFile,
                                                  builder: (context,
                                                      AsyncSnapshot<Uint8List>
                                                          snapshot) {
                                                    if (snapshot.hasData) {
                                                      this.image =
                                                          snapshot.data;
                                                      return Container(
                                                          alignment:
                                                              Alignment.center,
                                                          width: 56,
                                                          height: 56,
                                                          decoration:
                                                              BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image:
                                                                      DecorationImage(
                                                                          image:
                                                                              MemoryImage(
                                                                    snapshot
                                                                        .data,
                                                                  ))));
                                                    } else {
                                                      return Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: 56,
                                                        height: 56,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: user.logo != ''
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            56.0),
                                                                child: LoadImage.load(
                                                                    url: user
                                                                        .logo,
                                                                    height: 56,
                                                                    width: 56,
                                                                    fit: BoxFit
                                                                        .fitHeight))
                                                            : CrossPlatformSvg.asset(
                                                                assetPath:
                                                                    'assets/vectors/Icons/UserIcon.svg',
                                                                height: 56,
                                                                width: 56,
                                                                fit: BoxFit
                                                                    .fitHeight),
                                                      );
                                                    }
                                                  }),
                                            ));
                                      } else {
                                        return CircularProgressIndicator();
                                      }
                                    }),
                                SizedBox(height: 35),
                                MyTextFormField(
                                  controller: personPageWidgetNameController,
                                  text: Strings.PersonPageWidget_Name_label,
                                  hint: Strings.PersonPageWidget_Name_label,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  counterFontSize: 10,
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.name,
                                  maxLength: 20,validator:   NameValidator(3),
                                ),
                                SizedBox(height: 24),
                                MyTextFormField(
                                  controller: personPageWidgetFamilyController,
                                  text: Strings.PersonPageWidget_Family_label,
                                  hint: Strings.PersonPageWidget_Family_label,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  counterFontSize: 10,
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.name,
                                  maxLength: 35,validator:   FamilyValidator(3),
                                ),
                                /*  SizedBox(height: 24),
                             personPageWidgetNationalCode,*/
                                SizedBox(height: 24),
                                MyTextFormField(
                                  enabled: (this.user == null ||
                                      this.user.id == null),
                                  controller: personPageWidgetPhoneController,
                                  text: Strings.PersonPageWidget_Phone_label,
                                  hint: Strings.PersonPageWidget_Phone_label,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  counterFontSize: 10,
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 11,validator:   MobileValidator(11),
                                ),
                                SizedBox(height: 24),
                                MyTextFormField(
                                  enabled: false,
                                  controller:
                                      personPageWidgetNationalCodeController,
                                  text: Strings
                                      .PersonPageWidget_NationalCode_label,
                                  hint: Strings
                                      .PersonPageWidget_NationalCode_label,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  counterFontSize: 10,
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
                                ),
                                if (this.user != null) SizedBox(height: 24),
                                if (this.user != null &&
                                    locator<Constants>().getSite_id() != '')
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: MyText(
                                      text: Strings
                                          .PersonPageWidget_edit_your_factory_data,
                                      textAlign: TextAlign.right,
                                      color: ColorPalette.Black1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                if (locator<Constants>().getSite_id() != '')
                                  SizedBox(height: 24),
                                if (locator<Constants>().getSite_id() != '')
                                  personPageWidgetUnit,
                                if (locator<Constants>().getSite_id() != '')
                                  SizedBox(height: 24),
                                if (locator<Constants>().getSite_id() != '')
                                  personPageWidgetJobTitle,
                                if (locator<Constants>().getSite_id() != '')
                                  SizedBox(height: 24),
                                if (locator<Constants>().getSite_id() != '')
                                  MyDropDownFormField(
                                    selected: (user == null || user.id == null)
                                        ? null
                                        : DropDownItem(user.user_role.index,
                                            user.getRole(), null),
                                    httpEvent: DropDownGetPermissionEvent(),
                                    bottomSheetTitle: Strings
                                        .BottomSheetWidget_JoinCompany_permission,
                                    text: Strings.PersonPageWidget_permission,
                                    hint: Strings.PersonPageWidget_choose,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    onChange: (newValue) {
                                      this.user.user_role = role.values
                                          .firstWhere(
                                              (i) => i.index == newValue.id);
                                    },
                                  ),
                              ]),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            textDirection: TextDirection.rtl,
                            children: [
                              Expanded(
                                child: FractionallySizedBox(
                                  //alignment: Alignment.centerRight,
                                  widthFactor: 1,
                                  child: personPageWidgetCancel,
                                ),
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              Expanded(
                                child: FractionallySizedBox(
                                    //alignment: Alignment.centerRight,
                                    widthFactor: 1,
                                    child: personPageWidgetApprove),
                              )
                            ],
                          ),
                        )
                      ]))))),
        ));
  }
}
