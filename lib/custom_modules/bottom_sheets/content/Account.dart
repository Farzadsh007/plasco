import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';
import 'package:plasco/views/auth/EnterNoWidget.dart';
import 'package:plasco/views/company/CompanyPageWidget.dart';
import 'package:plasco/views/company/NewCompanyPageWidget.dart';
import 'package:plasco/views/group/GroupPageWidget.dart';
import 'package:plasco/views/location/LocationPageWidget.dart';
import 'package:plasco/views/person/NewPersonPageWidget.dart';
import 'package:plasco/views/relatedCompany/RelatedCompanyPageWidget.dart';

import '../../../locator.dart';
import '../../CrossPlatformSvg.dart';
import '../../LoadImage.dart';
import '../../inputs/MyText.dart';

class AccountWidget extends StatefulWidget {
  AccountWidget({
    Key key,
  }) : super(key: key);

  @override
  _AccountWidgetState createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  _AccountWidgetState();

  AuthEnterBloc httpBloc = AuthEnterBloc();
  MyBloc profileHttpBloc = MyBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpBloc.streamAuthEnterNo.listen((event) {
      if (event == true) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => EnterNoWidget()),
            (Route<dynamic> route) => false);
      }
    });
    Future.delayed(Duration.zero, () {
      locator<Web>().post(AuthGetProfileEvent(profileHttpBloc, null), context);
    });
  }

  @override
  void dispose() {
    httpBloc.dispose();
    profileHttpBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder(
            stream: profileHttpBloc.stream,
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                User user = snapshot.data as User;
                return Material(
                    color: Colors.transparent,
                    child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        onTap: () {
                          if (locator<Constants>()
                              .getSite_id() !=
                              '' && locator<Constants>().hasAccess(context,AccessEnum.editProfile, null,null)){
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    NewPersonPageWidget(user: user,isFromAdd: false,)));
                          }

                        },
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: user.logo != ''
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(56.0),
                                      child: LoadImage.load(
                                          url: user.logo,
                                          height: 56,
                                          width: 56,
                                          fit: BoxFit.fitHeight))
                                  : CrossPlatformSvg.asset(
                                      assetPath:
                                          'assets/vectors/Icons/AvatarPlaceHolder.svg',
                                      height: 56,
                                      width: 56,
                                      fit: BoxFit.fitHeight),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Row(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Align(
                                    alignment: Alignment.centerRight,
                                    widthFactor: 1 / 3,
                                    child: GestureDetector(
                                        onTap: () {},
                                        child: SvgPicture.asset(
                                          'assets/vectors/Icons/edit.svg',
                                          width: 22,
                                          height: 22,
                                          color: ColorPalette.Gray2,
                                        ))),
                                Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1 / 3,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        children: [
                                          MyText(
                                            text: user.first_name +
                                                ' ' +
                                                user.last_name,
                                            textAlign: TextAlign.center,
                                            color: ColorPalette.Black1,
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: MyText(
                                              text: user.job_title_name,
                                              textAlign: TextAlign.center,
                                              color: ColorPalette.Gray1,
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          )
                                        ],
                                      ),
                                    )),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: 1 / 3,
                                    child: user.getLabel()),
                              ],
                            )
                          ],
                        )));
              } else {
                return CircularProgressIndicator();
              }
            }),
        Card(
          elevation: 0,
          margin: EdgeInsets.only(top: 24),
          child: InkWell(
              splashColor: ColorPalette.Gray3,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CompanyPageWidget()));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorPalette.Gray2,
                            width: 2,
                          ),
                        ),
                        child: SvgPicture.asset(
                          'assets/vectors/Icons/plus.svg',
                          width: 22,
                          height: 22,
                          color: ColorPalette.Gray2,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: MyText(
                        text: Strings.BottomSheetWidget_Account_signIn,
                        textAlign: TextAlign.right,
                        color: ColorPalette.Black2,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                ),
              )),
        ),
        if (locator<Constants>().getSite_id() != '')
          Card(
            elevation: 0,
            margin: EdgeInsets.only(top: 24),
            child: InkWell(
                splashColor: ColorPalette.Gray3,
                onTap: () {
                  if (locator<Constants>()
                      .getSite_id() !=
                      '' && locator<Constants>().hasAccess(context,AccessEnum.editCompany, null,null)){
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NewCompanyPageWidget(
                          isForEdit: true,
                        )));
                  }

                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                          width: 22,
                          height: 22,
                          child: SvgPicture.asset(
                            'assets/vectors/Icons/settings.svg',
                            width: 22,
                            height: 22,
                            color: ColorPalette.Gray2,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: MyText(
                          text: Strings.BottomSheetWidget_Account_settings,
                          textAlign: TextAlign.right,
                          color: ColorPalette.Black2,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ],
                  ),
                )),
          ),
        if (locator<Constants>().getSite_id() != '')
          Card(
            elevation: 0,
            margin: EdgeInsets.only(top: 24),
            child: InkWell(
                splashColor: ColorPalette.Gray3,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GroupPageWidget()));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                          width: 22,
                          height: 22,
                          child: SvgPicture.asset(
                            'assets/vectors/Icons/users.svg',
                            width: 22,
                            height: 22,
                            color: ColorPalette.Gray2,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: MyText(
                          text: Strings.BottomSheetWidget_Account_groups,
                          textAlign: TextAlign.right,
                          color: ColorPalette.Black2,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ],
                  ),
                )),
          ),
        if (locator<Constants>().getSite_id() != '')
          Card(
            elevation: 0,
            margin: EdgeInsets.only(top: 24),
            child: InkWell(
                splashColor: ColorPalette.Gray3,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RelatedCompanyPageWidget()));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                          width: 22,
                          height: 22,
                          child: SvgPicture.asset(
                            'assets/vectors/Icons/briefcase.svg',
                            width: 22,
                            height: 22,
                            color: ColorPalette.Gray2,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: MyText(
                          text: Strings.BottomSheetWidget_Account_subFactories,
                          textAlign: TextAlign.right,
                          color: ColorPalette.Black2,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ],
                  ),
                )),
          ),
        if (locator<Constants>().getSite_id() != '')
          Card(
            elevation: 0,
            margin: EdgeInsets.only(top: 24),
            child: InkWell(
                splashColor: ColorPalette.Gray3,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LocationPageWidget()));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                          width: 22,
                          height: 22,
                          child: SvgPicture.asset(
                            'assets/vectors/Icons/map-pin.svg',
                            width: 22,
                            height: 22,
                            color: ColorPalette.Gray2,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: MyText(
                          text: Strings.BottomSheetWidget_Account_places,
                          textAlign: TextAlign.right,
                          color: ColorPalette.Black2,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ],
                  ),
                )),
          ),
        Card(
          elevation: 0,
          margin: EdgeInsets.only(top: 24),
          child: InkWell(
              splashColor: ColorPalette.Gray3,
              onTap: () {
                locator<Web>().post(AuthLogOutEvent(httpBloc), context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                        width: 22,
                        height: 22,
                        child: SvgPicture.asset(
                          'assets/vectors/Icons/log-out.svg',
                          width: 22,
                          height: 22,
                          color: ColorPalette.Gray2,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: MyText(
                        text: Strings.BottomSheetWidget_Account_signOut,
                        textAlign: TextAlign.right,
                        color: ColorPalette.Black2,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                ),
              )),
        ),
      ],
    );
  }
}
