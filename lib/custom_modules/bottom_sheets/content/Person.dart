import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/views/person/NewPersonPageWidget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../locator.dart';
import '../../../strings.dart';
import '../../CrossPlatformSvg.dart';
import '../../LoadImage.dart';
import '../../inputs/MyText.dart';

class PersonWidget extends StatefulWidget {
  PersonWidget({Key key, this.user}) : super(key: key);

  final User user;

  @override
  _PersonWidgetState createState() => _PersonWidgetState(this.user);
}

class _PersonWidgetState extends State<PersonWidget> {
  _PersonWidgetState(this.user);

  User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              alignment: Alignment.centerRight,
              width: 64,
              height: 64,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: user.logo != ''
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(64.0),
                      child: LoadImage.load(
                          url: user.logo,
                          height: 64,
                          width: 64,
                          fit: BoxFit.fitHeight))
                  : CrossPlatformSvg.asset(
                      assetPath: 'assets/vectors/Icons/AvatarPlaceHolder.svg',
                      height: 64,
                      width: 64,
                      fit: BoxFit.fitHeight),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MyText(
                    text: user.first_name + ' ' + user.last_name,
                    textAlign: TextAlign.right,
                    color: ColorPalette.Black1,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                  SizedBox(height: 4),
                  MyText(
                    text: user.job_title_name,
                    textAlign: TextAlign.right,
                    color: ColorPalette.Gray1,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  )
                ],
              ),
            )
          ],
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
                      text: Strings.BottomSheetWidget_Person_call,
                      buttonFill: ButtonFillStyle.White,
                      onPressed: () {
                        launch("tel://${this.user.mobile_number}");
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
                        text: Strings.BottomSheetWidget_Person_details,
                        buttonFill: ButtonFillStyle.Yellow,
                        onPressed: () {
    if (locator<Constants>()
        .getSite_id() !=
    '' && locator<Constants>().hasAccess(context,AccessEnum.editProfile, null,null)) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              NewPersonPageWidget(user: user,isFromAdd: false,)));

    }

                        })),
              )
            ],
          ),
        )
      ],
    );
  }
}
