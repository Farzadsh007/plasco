import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/strings.dart';
import 'package:plasco/views/anomaly/AnomalyPageWidget.dart';
import 'package:plasco/views/person/PersonPageWidget.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class MainPagePlans extends StatefulWidget {
  @override
  _MainPagePlansState createState() => _MainPagePlansState();
}

class _MainPagePlansState extends State<MainPagePlans> {
  Future<bool> _willPopCallback() async {
    bool ret = true;

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SizedBox(height: 24,),
        Container(
            alignment: Alignment.centerRight,
            child: MyText(
              text: Strings.MainPageWidget_plans,
              textAlign: TextAlign.right,
              color: ColorPalette.Black1,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
        SizedBox(
          height: 24,
        ),

        Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
                width: 104,
                height: 106,
                // padding: EdgeInsets.symmetric(horizontal: 32.0,vertical: 16.0),
                decoration: BoxDecoration(
                    color: ColorPalette.White1,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                          color: ColorPalette.White1.withOpacity(0.25),
                          offset: Offset(0, 0),
                          blurRadius: 4)
                    ]),
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        onTap: () {
                          if (locator<Constants>().getSite_id() != '')
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PersonPageWidget()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/vectors/Icons/Person.svg',
                                width: 40,
                                height: 40,
                              ),
                              FittedBox(
                                child: MyText(
                                  text: Strings.MainPageWidget_plans_person,
                                  textAlign: TextAlign.center,
                                  color: ColorPalette.Black1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        )))),
            SizedBox(
              width: 8,
            ),
            Container(
                width: 104,
                height: 106,
                // padding: EdgeInsets.symmetric(horizontal: 32.0,vertical: 16.0),
                decoration: BoxDecoration(
                    color: ColorPalette.White1,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                          color: ColorPalette.White1.withOpacity(0.25),
                          offset: Offset(0, 0),
                          blurRadius: 4)
                    ]),
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        onTap: () {
                          if (locator<Constants>().getSite_id() != '')
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AnomalyPageWidget()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/vectors/Icons/Anomaly.svg',
                                width: 40,
                                height: 40,
                              ),
                              FittedBox(
                                child: MyText(
                                  text: Strings.MainPageWidget_plans_anomaly,
                                  textAlign: TextAlign.center,
                                  color: ColorPalette.Black1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ))))
          ],
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
