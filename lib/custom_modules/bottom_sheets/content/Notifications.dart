import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/color_palette.dart';

import '../../../strings.dart';
import '../../CrossPlatformSvg.dart';
import '../../inputs/MyText.dart';

class NotificationsWidget extends StatefulWidget {
  NotificationsWidget(
      {Key key,
      })
      : super(key: key);



  @override
  _NotificationsWidgetState createState() => _NotificationsWidgetState();

}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  _NotificationsWidgetState( );


  int selectedRadio;

  Widget getListItem(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      textDirection: TextDirection.rtl,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          alignment: Alignment.centerRight,
          width: 24,
          height: 24,
          decoration:
              BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4))),
          child: CrossPlatformSvg.asset(
              assetPath: 'assets/vectors/logo.svg',
              height: 24,
              width: 24,
              fit: BoxFit.fitHeight),
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
                          text: 'Strings',
                          textAlign: TextAlign.right,
                          color: ColorPalette.Black1,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                        SizedBox(height: 4),
                        MyText(
                          text: 'St',
                          textAlign: TextAlign.right,
                          color: ColorPalette.Gray2,
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                        )
                      ],
                    ),
                  ])),
        ),
        Container(
          decoration: BoxDecoration(
              color: ColorPalette.Red1.withOpacity(0.1),
              borderRadius: BorderRadius.all(Radius.circular(4))),
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
          child: MyText(
            text: 'تایید شده',
            textAlign: TextAlign.center,
            color: ColorPalette.Red1,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          )
          /*        MyText(
           text:'تایید شده',
    textAlign: TextAlign.center,
    color: ColorPalette.Green1,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    )*/
          ,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
            alignment: Alignment.centerRight,
            child: MyText(
              text: Strings.BottomSheetWidget_Notifications_header,
              textAlign: TextAlign.right,
              color: ColorPalette.Black2,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            )),
        Container(
            height: 200,
            child: SingleChildScrollView(
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
                    shrinkWrap: true,
                    itemCount: 20,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return getListItem(index);
                    }))),
      ],
    );
  }
}
